class LocationPlansController < ApplicationController
  before_action :set_location_plan, only: [:show, :edit, :update, :destroy]
  before_action :set_location_plans, only: [:index]

  skip_after_filter :verify_authorized, only: [:approve]
  after_action :verify_policy_scoped, only: [:approve]

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
    if params[:copy_grade]
      @location_plan.copy_grade!
      redirect_to @location_plan, notice: 'You may now edit the coverage for this location.'
    elsif @location_plan.update(location_plan_params)
      redirect_to @location_plan#, notice: 'LocationPlan was successfully updated.'
    else
      render :show
    end
  end

  def approve
    ids = Array(params[:location_plan_ids])

    @location_plans = policy_scope(LocationPlan).where(id: ids)

    if params[:reject]
      @location_plans.update_all(approval_state: LocationPlan.approval_states[:pending])
    else
      @location_plans.update_all(approval_state: LocationPlan.approval_states[:approved])
    end

    lp = @location_plans.first
    redirect_to schedule_location_plans_url(lp.schedule_id, zone_id: lp.location.zone_id)
  end

  private

  # For index
  def set_location_plans
    @schedule = Schedule.find(params[:schedule_id])
    authorize @schedule, :show?

    @zone = if params[:zone_id]
              user_zones.find(params[:zone_id].to_i)
            else
              user_zones.ordered.first
            end

    authorize @zone

    @zones = user_zones.ordered
    @location_plans = @schedule.location_plans.for_zone(@zone).includes(:location).ordered
  end

  # For member actions
  def set_location_plan
    @location_plan = LocationPlan.find(params[:id])
    authorize @location_plan

    @zone = @location_plan.location.zone

    @schedule = @location_plan.schedule
    authorize @schedule, :show?

    # These are used for the nav header
    @zones = user_zones.ordered
    @location_plans = @schedule.location_plans.for_zone(@zone).includes(:location).ordered
  end

  # Only allow a trusted parameter "white list" through.
  def location_plan_params
    params.require(:location_plan).permit(:chosen_grade_id)
  end
end
