class StaffingAnalystController < ApplicationController

  skip_after_filter :verify_policy_scoped, only: [:index]

  def index
    authorize current_user, :index?
  end

end
