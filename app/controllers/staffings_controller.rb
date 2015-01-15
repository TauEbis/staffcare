class StaffingsController < ApplicationController
  before_filter :set_schedule

  def show

  end

  def table
    render json: {"Hello" => "World"}
  end


  protected

  def set_schedule
    @schedule = Schedule.find(params[:schedule_id])
    authorize @schedule
  end
end
