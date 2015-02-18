class ShortForecastsController < ApplicationController

  before_action :set_short_forecast, only: [:show]

  # GET /short_forecasts
  def index
    start_date = ShortForecast.first.start_date
    end_date = ShortForecast.first.end_date
    @short_forecasts = policy_scope(ShortForecast).where(start_date: start_date, end_date: end_date)
    @dates = (start_date..end_date).select{ |date| date.wday == 0 }
  end

  # GET /short_forecasts/1
  def show
  	@times = @short_forecast.times
    week = params[:week].to_i
    @start_date = @short_forecast.start_date + week.weeks
    @prev = [ week - 1 , 0 ].max
    @next = [ week + 1 , @short_forecast.forecast_window-1 ].min
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_short_forecast
      @short_forecast =ShortForecast.find(params[:id])
      authorize @short_forecast
    end
end