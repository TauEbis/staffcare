class LandingPagesController < ApplicationController

  skip_after_filter :verify_policy_scoped

  def staffing_analyst
    authorize current_user, :index?
  end

  def report_server_data_and_forecasts
    authorize current_user, :index?
  end

end
