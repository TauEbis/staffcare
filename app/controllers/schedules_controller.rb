class SchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :destroy]

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized, only: [:index]

  # GET /schedules
  def index
    @schedules = policy_scope(Schedule).ordered.page params[:page]
    authorize @schedules
    @zones = user_zones.assigned.ordered
  end

  # GET /schedules/1
  def show
    redirect_to schedule_location_plans_url(params[:id])
  end

  # GET /schedules/new
  def new
    @schedule = Schedule.new(Schedule.default_attributes)
    authorize @schedule
  end

  # GET /schedules/1/edit
  def edit
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
      redirect_to @schedule, notice: 'Schedule was successfully updated.'
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
      params.require(:schedule).permit(:starts_on, :state, *Schedule::OPTIMIZER_FIELDS)
    end

    # Custom Pundit error message.
    def user_not_authorized
      flash[:error] = "No active schedules"
      redirect_to(request.referrer || root_path)
    end

end
