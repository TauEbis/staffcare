class CoveragesController < ApplicationController
  before_action :set_coverage, only: [:show]

  # GET /coverages/1
  def show
    @schedule = Schedule.first
    authorize @schedule
  end

  private

  def set_coverage
    #@coverage = .find(params[:id])
    #authorize @coverage
  end
end
