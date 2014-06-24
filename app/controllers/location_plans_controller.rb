class LocationPlansController < ApplicationController
  before_action :set_location_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_zones, only: [:index, :show]

  # GET /schedule/:schedule_id/location_plans
  # Also expects a :zone_id param as a filter
  def index
    @schedule = Schedule.find(params[:schedule_id])
    authorize @schedule
  end

  # GET /location_plans/1
  def show
    #@schedule = @location_plan.schedule(params[:schedule_id])
    # TODO: Lookup the real schedule!
    @schedule = Schedule.first
    authorize @schedule
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

  def set_zones
    @zones = user_zones.ordered
    @zone = if params[:zone_id]
              user_zones.find(params[:zone_id].to_i)
            else
              user_zones.ordered.first
            end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_location_plan
    # TODO: This should be a lookup on LocationPlan id, but we don't have that model yet
    @location_plan = Location.find(params[:id])
    authorize @location_plan
  end

  # Only allow a trusted parameter "white list" through.
  def location_plan_params
    #params.require(:location_plan).permit(:name, :zone_id, :rooms, :max_mds, :report_server_id, *LocationPlan::DAY_PARAMS)
  end
end