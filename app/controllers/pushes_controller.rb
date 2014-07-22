class PushesController < ApplicationController
  before_filter :set_location_plan, only: [:new, :create]

  def new
    @pusher = WiwPusher.new(@location_plan)
    @push = @pusher.push
  end

  def create
  end

  def show
  end

  protected

  def set_location_plan
    @location_plan = policy_scope(LocationPlan).find(params[:location_plan_id])
    authorize @location_plan
  end
end
