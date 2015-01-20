class PushesController < ApplicationController
  before_filter :set_push, only: [:show]
  before_filter :set_schedule, only: [:index, :new]
  before_filter :set_location_plans, only: [:confirm, :create]

  def index
    @pushes = Push.includes(:location_plan => :location).where(location_plan_id: @schedule.location_plan_ids).ordered.page params[:page]
  end

  def new
    @zones = Zone.assigned
    @location_plans = @location_plans.group_by{|lp| lp.location.zone_id }
    #set_location_plans unless @schedule
    #redirect_to '/', alert: "Must have a location or a schedule to start a push" if !@schedule && !@location_plans
  end

  def create
    group_id = Time.now.utc.to_i

    # This isn't wrapped in a transaction because it's generally okay if some get pushed and some don't
    @location_plans.each do |location_plan|
      push = location_plan.pushes.create!

      job_id = PushWorker.perform_async(push.id)
      push.update_attributes( job_id: job_id, group_id: group_id )
    end

    redirect_to pushes_url(schedule_id: @location_plans.first.schedule.id )
  end

  def show
  end

  protected

  def set_schedule
    if params[:schedule_id]
      @schedule = policy_scope(Schedule).find(params[:schedule_id])
      authorize @schedule, 'push?'
      @location_plans = @schedule.location_plans.includes(:location).ordered.merge(user_locations).assigned
    elsif params[:location_plan_id]
      @location_plans = [policy_scope(LocationPlan).find(params[:location_plan_id])].assigned
      @schedule = @location_plans.first.schedule_id
      authorize @schedule, 'push?'
    end
  end

  def set_location_plans
    if params[:location_plan_ids]
      @location_plans = policy_scope(LocationPlan).where(id: Array(params[:location_plan_ids]))
      @location_plans.each {|lp| authorize lp, 'push?'}
    else
      redirect_to new_push_url(schedule_id: params[:schedule_id]), alert: "You must select at least one location."
    end
  end

  def set_push
    @push = Push.find(params[:id])
    authorize @push
  end
end
