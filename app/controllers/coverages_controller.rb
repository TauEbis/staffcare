class CoveragesController < ApplicationController
  before_action :set_coverage, only: [:show]

  # GET /coverages/1
  def show
    @date = params[:detail_date]

    @location_plan = policy_scope(LocationPlan).find(params[:id])
    authorize @location_plan

    # TODO: Really look up the grade
    @grade = @location_plan.grades.first

    render layout: false
  end

  private

  def set_coverage
    #@coverage = .find(params[:id])
    #authorize @coverage
  end
end
