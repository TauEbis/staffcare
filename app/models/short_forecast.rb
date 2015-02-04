class ShortForecast < ActiveRecord::Base

	belongs_to :location
	belongs_to :report_server_ingest

  validates :visits, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :location, presence: true, uniqueness: true

  def weekly_total(date) # date is assumed to be a sunday
		(date..(date + 6.days)).inject(0) { |acc, d| acc + visits[d.to_s].values.sum }
  end

  def times
  	visits.values.first.keys.sort
  end

  # Class method to rebuild the shrort forecasts. Called every week by a rake task
	def self.build_latest!
		forecast_window = 12 # weeks to forecast
		start_date = Date.today - Date.today.wday
		end_date = start_date + forecast_window.weeks - 1.days

		lookback_window = 10 # weeks of data to look at
		date_range = VolumeForecaster.calc_data_date_range(lookback_window)
    locations = VolumeForecaster.locations_with_sufficient_data(date_range)

		locations.each do |location|
			short_forecast = ShortForecast.where(location: location).first_or_initialize

      forecaster = VolumeForecaster.new(date_range, location)
      volumes = forecaster.full_forecast(start_date, end_date)
      visits = VisitBuilder.new.build_visits(volumes, location.heatmap, :volume_forecaster, {keep_times: true})

			attr = { forecast_window: forecast_window, start_date: start_date, end_date: end_date, visits: visits,
						 	 lookback_window: lookback_window, forecaster_opts: forecaster.opts, lookback_data: forecaster.lookback_data,
						 	 report_server_ingest: Visit.where(location: location).ordered.last.report_server_ingest }

			short_forecast.update(attr)
			short_forecast.save!
		end
	end

end