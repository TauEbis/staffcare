class DashboardController < ApplicationController
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  def index
    @schedules = Schedule.active.ordered

    p = TodoPresenter.new(current_user)
    @todos = p.location_plans
    unless current_user.manager?
      @minions = p.minions
    end
  end

  def status
  end
end
