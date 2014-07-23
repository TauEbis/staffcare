class PushesController < ApplicationController
  before_filter :set_push, only: [:show]
  before_filter :set_location_plan, only: [:new, :create]

  def new
    @pusher = WiwPusher.new(@location_plan)
    @push = @pusher.push
  end

  def create
    @pusher = WiwPusher.new(@location_plan)
    @push   = @pusher.push

    if @push.save
      job_id = PushWorker.perform_async(@push.id)
      @push.update_attribute( :job_id, job_id )
      redirect_to @push
    else
      render 'new', alert: @pusher.push.errors.full_messages.join(', ')
    end
  end

  def show
  end

  protected

  def set_location_plan
    @location_plan = policy_scope(LocationPlan).find(params[:location_plan_id])
    authorize @location_plan
  end

  def set_push
    @push = Push.find(params[:id])
    authorize @push
  end
end
