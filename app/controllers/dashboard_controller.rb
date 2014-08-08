class DashboardController < ApplicationController
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  def index
    @todos = TodoPresenter.new(current_user).to_a
  end

  def status
  end
end
