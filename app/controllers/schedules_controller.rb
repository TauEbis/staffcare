class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :request_approvals, :update, :destroy]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /schedules
  def index
    @schedules = policy_scope(Schedule).ordered.page params[:page]
    authorize @schedules

  end

  # GET /schedules/1
  def show
    #redirect_to schedule_location_plans_url(params[:id])
    @zones = user_zones.assigned.ordered
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new(Schedule.default_attributes)
    authorize @schedule
  end

  # GET /schedules/1/edit
  def edit
  end

  def request_approvals
    @schedule.manager_deadline ||= @schedule.starts_on - 21
    @schedule.gm_deadline ||= @schedule.starts_on - 14
    @schedule.sync_deadline ||= @schedule.starts_on - 7
    @schedule.state = :active
    flash[:dashboard] = true if params[:dashboard]
  end

  # POST /schedules
  def create
    @schedule = Schedule.new(schedule_params)
    authorize @schedule

    if @schedule.save
      job_id = OptimizerWorker.perform_async(@schedule.id)
      @schedule.update_attribute( :optimizer_job_id, job_id )

      redirect_to schedules_url, notice: 'Schedule was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /schedules/1
  def update
    if @schedule.update(schedule_params)
      if params[:notify_managers]
        TodoNotifier.notify!
        @schedule.update_attribute(:active_notices_sent_at, Time.now.utc)
      end

      if flash[:dashboard]
        redirect_to root_path, notice: 'Schedule was successfully updated.'
      else
        redirect_to @schedule, notice: 'Schedule was successfully updated.'
      end
    else
      render :edit
    end
  end

  # DELETE /schedules/1
  def destroy
    @schedule.destroy
    redirect_to schedules_url, notice: 'Schedule was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_schedule
      @schedule = Schedule.find(params[:id])
      authorize @schedule
    end

    # Only allow a trusted parameter "white list" through.
    def schedule_params
      params.require(:schedule).permit(:starts_on, :state, :manager_deadline, :gm_deadline, :sync_deadline, *Schedule::OPTIMIZER_FIELDS)
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
