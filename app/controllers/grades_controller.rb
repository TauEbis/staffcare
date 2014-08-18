class GradesController < ApplicationController
  before_action :set_location_plan, only: [:create]
  before_action :set_grade, only: [:show, :highcharts, :hourly, :update, :destroy]

  def create
    authorize Grade.new(location_plan: @location_plan), :create?  # Fake grade, the real one to be created later
    @grade = @location_plan.copy_grade!(current_user)
    redirect_to @location_plan, notice: 'You may now edit the coverage for this location.'
  end

  # GET /coverages/1
  def show
    pts     = Grade.unoptimized_sum(@grade)

    data = { chosen_grade_id: @grade.id,
             source: @grade.source,
             editable: policy(@grade).update?,
             grade_points: pts,
             grade_hours:  pts['hours']
            }

    if @date
      data[:day_info] = {
        date: @date.to_s,
        formatted_date: I18n.localize(@date, format: :with_dow),
        open_time: @location_plan.open_times[@date.wday],
        close_time: @location_plan.close_times[@date.wday],
      }
      data[:day_points] = @grade.points[@date_s]
      data[:shifts]     = @grade.shifts.for_day(@date).map(&:to_knockout)
    end

    render json: data
  end

  def highcharts
    render json: @grade.for_highcharts(@date)
  end

  def hourly
    render layout: false
  end

  # PATCH /coverages/:location_plan_id
  def update
    @grade.update_shift!(@date, params[:shifts])
    @grade.location_plan.dirty!
    render text: "OK!"
  end

  def destroy
    @grade.location_plan.dirty!
    @grade.destroy
    redirect_to @location_plan, notice: 'Coverage plan was successfully destroyed.'
  end

  private

  def set_grade
    if params[:date]
      @date = Date.parse params[:date]
      @date_s = params[:date]
    end

    @grade = policy_scope(Grade).find(params[:id])
    authorize @grade

    @location_plan = @grade.location_plan
  end

  def set_location_plan
    @location_plan = policy_scope(LocationPlan).find(params[:location_plan_id])
  end
end
