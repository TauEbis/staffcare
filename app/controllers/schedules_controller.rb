class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :request_approvals, :update, :destroy]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /schedules
  def index
    @schedules = policy_scope(Schedule)
      .ordered
      .includes(location_plans: [{chosen_grade: :visit_projection}, :location])
      .page params[:page]
    authorize @schedules
  end

  # GET /schedules/1
  def show
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new(Schedule.default_attributes)
    authorize @schedule
  end

  # GET /schedules/1/edit
  def edit
    @editing = true
    @updates = @schedule.check_for_updates
  end

  def request_approvals
    @schedule.manager_deadline ||= @schedule.starts_on - 31
    @schedule.rm_deadline ||= @schedule.starts_on - 24
    @schedule.sync_deadline ||= @schedule.starts_on - 17
    @schedule.state = :active
    flash[:dashboard] = true if params[:dashboard]
  end

  # POST /schedules
  def create
    @schedule = Schedule.new(schedule_params)
    authorize @schedule

    if @schedule.save
      job_id = ScheduleOptimizerWorker.perform_async(@schedule.id)
      @schedule.update_attribute( :optimizer_job_id, job_id )

      redirect_to schedules_url, notice: 'Schedule was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /schedules/1
  def update
    if @schedule.update(schedule_params)

      if params[:editing]
        lp_ids = @schedule.location_plans.pluck(:id)
        grade_ids = Grade.where(location_plan_id: lp_ids).pluck(:id)
        shift_ids = Shift.where(grade_id: grade_ids).pluck(:id)
        Grade.where(id: grade_ids).delete_all
        Shift.where(id: shift_ids).delete_all

        @schedule.location_plans.map(&:not_run!)

        opts = { 'load_locations' => params[:load_locations], 'load_visits' => params[:load_visits] } # sidekiq / redis don't support symbols in arguments
        job_id = ScheduleOptimizerWorker.perform_async(@schedule.id, opts)
        @schedule.update_attribute( :optimizer_job_id, job_id )

        redirect_to schedules_url, notice: 'Schedule was successfully updated. Optimization is now running.'
      else

        if params[:notify_managers]
          TodoNotifier.notify!
          @schedule.update_attribute(:active_notices_sent_at, Time.now.utc)
        end

        redirect_to (flash[:dashboard] ? root_path: @schedule), notice: 'Schedule deadlines were successfully set.'
      end

    else
      @editing = true
      @updates = @schedule.check_for_updates
      render :edit
    end
  end

  # DELETE /schedules/1
  def destroy
    if ScheduleDestroyer.new(@schedule).destroy
      redirect_to schedules_url, notice: 'Schedule was successfully destroyed.'
    else
      redirect_to schedules_url, alert: 'Something went wrong. Schedule was not destroyed.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.includes(location_plans: [{location: [:zone]}, :chosen_grade]).find(params[:id])
      authorize @schedule
    end

    # Only allow a trusted parameter "white list" through.
    def schedule_params
      params.require(:schedule).permit(:starts_on, :state, :manager_deadline, :rm_deadline, :sync_deadline, *Schedule::OPTIMIZER_FIELDS)
    end

    # Custom Pundit error message.
    def user_not_authorized
      if params[:action] == "index"
        flash[:error] = "No active schedules"
      else
        flash[:error] = "Access Denied"
      end
      redirect_to(request.referrer || root_path)
    end

end
