class LocationPlansController < ApplicationController
  before_action :set_location_plan, only: [:show, :edit, :update]
  before_action :set_location_plans, only: [:index]
  before_action :send_manager_to_location_plan, only: [:index]
  before_action :set_basics, only: [:index, :show, :edit, :update]

  skip_after_filter :verify_authorized, only: [:change_state]
  after_action :verify_policy_scoped, only: [:change_state]

  # GET /schedule/:schedule_id/location_plans
  # Also expects a :zone_id param as a filter
  # If it receives a location_plan_id, it redirects
  def index
    if !params[:location_plan_id].blank?
      redirect_to location_plan_url(params[:location_plan_id])
    end
  end

  # GET /location_plans/1
  def show
    @grade = @location_plan.chosen_grade
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
      redirect_to @location_plan#, notice: 'LocationPlan was successfully updated.'
    else
      render :show
    end
  end

  def change_state
    ids = Array(params[:location_plan_ids])

    @location_plans = policy_scope(LocationPlan).where(id: ids)

    state = LocationPlan.approval_states[params[:state]]
    if state
      @location_plans.update_all(approval_state: state)
    else
      flash[:alert] = "#{params[:state]} is not a valid state"
    end

    lp = @location_plans.first
    redirect_to schedule_location_plans_url(lp.schedule_id, zone_id: lp.location.zone_id)
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
  end

  def send_manager_to_location_plan
    if current_user.single_manager?
      params[:location_plan_id] = @schedule.location_plans.for_user(current_user).first
    end
  end

  # For member actions
  def set_location_plan
    @location_plan = LocationPlan.includes(:chosen_grade, :location).find(params[:id])
    authorize @location_plan

    @zone     = @location_plan.location.zone
    @schedule = @location_plan.schedule
  end

  def set_basics
    authorize @schedule, :show?
  end

  # Only allow a trusted parameter "white list" through.
  def location_plan_params
    params.require(:location_plan).permit(:chosen_grade_id)
  end
end
