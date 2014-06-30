class CoveragesController < ApplicationController
  before_action :set_coverage, only: [:show, :hourly, :update]

  # GET /coverages/1
  def show
    data = { location_plan_id: @location_plan.id,
             date: @date.to_s,
             open_time: @location_plan.open_times[@date.wday],
             close_time: @location_plan.close_times[@date.wday],
             shifts: @location_plan.shifts(@grade, @date),
             source: @grade.source,
             formatted_date: I18n.localize(@date, format: :with_dow)
            }
    render json: data
  end

  def hourly
    render layout: false
  end

  # PATCH /coverages/:location_plan_id
  def update
    @grade.update_shift!(@date_s, @date.wday, params[:shifts])
    render text: "OK!"
  end

  private

  def set_coverage
    @date = Date.parse params[:date]
    @date_s = params[:date]

    @location_plan = policy_scope(LocationPlan).find(params[:id])
    authorize @location_plan

    @grade = @location_plan.chosen_grade
  end
end
