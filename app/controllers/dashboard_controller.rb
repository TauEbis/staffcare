class DashboardController < ApplicationController
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  def index
    if user_locations.assigned.empty?
      @schedules = []
    else
      @schedules = Schedule.active.has_deadlines.ordered
    end

    p = TodoPresenter.new(current_user)
    @todos = p.location_plans
    unless current_user.manager?
      @minions = p.minions
    end
  end

  def status
  end
end
