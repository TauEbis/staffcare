class GradesController < ApplicationController
  before_action :set_grade, only: [:show, :hourly, :update]

  # GET /coverages/1
  def show
    pts = @grade.points[@date_s]

    data = { location_plan_id: @location_plan.id,
             total: pts['total'],
             md_sat: pts['md_sat'],
             patient_sat: pts['patient_sat'],
             cost: pts['cost'],
             date: @date.to_s,
             formatted_date: I18n.localize(@date, format: :with_dow),
             open_time: @location_plan.open_times[@date.wday],
             close_time: @location_plan.close_times[@date.wday],
             source: @grade.source,

             shifts: @grade.shifts[@date.to_s]
            }

    render json: data
  end

  def hourly
    render layout: false
  end

  # PATCH /coverages/:location_plan_id
  def update
    @grade.update_shift!(@date, @date.wday, params[:shifts])
    render text: "OK!"
  end

  private

  def set_grade
    @date = Date.parse params[:date]
    @date_s = params[:date]

    @location_plan = policy_scope(LocationPlan).find(params[:id])
    authorize @location_plan

    @grade = @location_plan.chosen_grade
  end
end
