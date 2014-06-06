class DashboardController < ApplicationController
  skip_after_filter :verify_authorized
  skip_after_filter :verify_policy_scoped

  def index
  end
end
