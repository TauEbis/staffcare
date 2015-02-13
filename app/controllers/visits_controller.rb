class VisitsController < ApplicationController

  before_action :set_visit, only: [:show]
  skip_after_filter :verify_policy_scoped, only: [:index]

  # GET /visits
  def index
    authorize Visit
    @dates = Kaminari.paginate_array(Visit.date_range.map(&:to_s)).page(params[:page]).per(7*4)
    @totals = Visit.totals_by_date_by_location(@dates.first..@dates.last)
    @locations = Location.ordered.all

    respond_to do |format|
      format.html
      format.csv { send_data Visit.to_csv }
    end
  end

  # GET /visits/am_pm
  def am_pm
    authorize Visit
    respond_to do |format|
      format.csv { send_data Visit.am_pm_to_csv }
    end
  end

  # GET /visits/1
  def show
  	@times = @visit.volumes.keys.sort
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_visit
      @visit = Visit.find(params[:id])
      authorize @visit
    end
end