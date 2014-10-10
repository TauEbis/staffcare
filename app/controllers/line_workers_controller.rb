class LineWorkersController < ApplicationController
  before_action :set_location_plan

  # TODO WARNING DON'T LET THESE STAY!
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  # GET /life_cycles
  def index
    # @life_cycles = policy_scope(LifeCycle).all
    @day = @location_plan.schedule.starts_on
    @life_cycle = LifeCycle.find(1)

  end

  # GET /life_cycles/new
  def new
    @life_cycle = LifeCycle.new
    authorize @life_cycle
  end

  # GET /life_cycles/1/edit
  def edit
  end

  # POST /life_cycles
  def create
    @life_cycle = LifeCycle.new(life_cycle_params)

    if @life_cycle.save
      redirect_to @life_cycle, notice: 'Life cycle was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /life_cycles/1
  def update
    if @life_cycle.update(life_cycle_params)
      redirect_to @life_cycle, notice: 'Life cycle was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /life_cycles/1
  def destroy
    @life_cycle.destroy
    redirect_to life_cycles_url, notice: 'Life cycle was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_location_plan
    @location_plan = LocationPlan.find(params[:location_plan_id])
    authorize @location_plan
  end

  # Only allow a trusted parameter "white list" through.
  def life_cycle_params
    params.require(:life_cycle).permit(:name, :min_daily_volume, :max_daily_volume, :scribe_policy, :pcr_policy, :ma_policy, :xray_policy, :am_policy, :default)
  end
end
