class LandingPagesController < ApplicationController

  skip_after_filter :verify_policy_scoped

  before_filter only: [:staffing_analyst, :report_server_data_and_forecasts] do |f|
    authorize current_user, :index?
  end

  def staffing_analyst
  end

  def report_server_data_and_forecasts
  end

end
