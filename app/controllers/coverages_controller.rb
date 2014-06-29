class CoveragesController < ApplicationController
  before_action :set_coverage, only: [:show, :hourly]

  # GET /coverages/1
  def show
    @date = Date.parse params[:date]
    @date_s = params[:date]

    @location_plan = policy_scope(LocationPlan).find(params[:id])
    authorize @location_plan

    @grade = @location_plan.chosen_grade

    render layout: false
  end

  def hourly
    @date = Date.parse params[:date]
    @date_s = params[:date]

    @location_plan = policy_scope(LocationPlan).find(params[:id])
    authorize @location_plan

    @grade = @location_plan.chosen_grade

    render layout: false
  end

  private

  def set_coverage
    #@coverage = .find(params[:id])
    #authorize @coverage
  end
end
