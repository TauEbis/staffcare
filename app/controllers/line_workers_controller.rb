class LineWorkersController < ApplicationController
  before_action :set_location_plan

  # TODO WARNING DON'T LET THESE STAY!
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  # GET location_plans/:location_plan_id/line_workers
  def index
    # @life_cycles = policy_scope(LifeCycle).all
    @day = @location_plan.schedule.starts_on
    @life_cycle = LifeCycle.find(1)

  end

  # GET location_plans/:location_plan_id/line_workers/new
  def new
    #@life_cycle = LifeCycle.new
    #authorize @life_cycle

  end

  # GET /life_cycles/1/edit
  def edit
  end

  # POST /life_cycles
  def create
    @location_plan.update(new_line_worker_params)

    gen = LineWorkerShiftGenerator.new(@location_plan)

    if gen.create!
      redirect_to location_plan_line_workers_url(@location_plan), notice: 'Line worker schedules generated successfully'
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
    @schedule = @location_plan.schedule
    authorize @location_plan
  end

  # Only allow a trusted parameter "white list" through.
  def new_line_worker_params
    params.require(:location_plan).permit(:life_cycle_id, :scribe_policy, :pcr_policy, :ma_policy, :xray_policy,
      :am_policy)
  end
end
