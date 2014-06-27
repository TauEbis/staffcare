class LocationPlansController < ApplicationController
  before_action :set_location_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_location_plans, only: [:index]

  # GET /schedule/:schedule_id/location_plans
  # Also expects a :zone_id param as a filter
  def index
  end

  # GET /location_plans/1
  def show
  end

  # POST /location_plans
  def create
    @location_plan = LocationPlan.new(location_plan_params)
    authorize @location_plan

    if @location_plan.save
      redirect_to @location_plan, notice: 'LocationPlan was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /location_plans/1
  def update
    if @location_plan.update(location_plan_params)
      redirect_to @location_plan, notice: 'LocationPlan was successfully updated.'
    else
      render :edit
    end
  end

  private

  # For index
  def set_location_plans
    @schedule = Schedule.find(params[:schedule_id])

    @zone = if params[:zone_id]
              user_zones.find(params[:zone_id].to_i)
            else
              user_zones.ordered.first
            end

    authorize @zone

    @zones = user_zones.ordered
    @location_plans = @schedule.location_plans.for_zone(@zone).includes(:location)
  end

  # For member actions
  def set_location_plan
    @location_plan = LocationPlan.find(params[:id])
    authorize @location_plan

    @zone = @location_plan.location.zone

    @schedule = @location_plan.schedule

    # These are used for the nav header
    @zones = user_zones.ordered
    @location_plans = @schedule.location_plans.for_zone(@zone).includes(:location)
  end

  # Only allow a trusted parameter "white list" through.
  def location_plan_params
    #params.require(:location_plan).permit(:name, :zone_id, :rooms, :max_mds, :report_server_id, *LocationPlan::DAY_PARAMS)
  end
end
