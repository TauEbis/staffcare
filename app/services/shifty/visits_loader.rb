class VisitsLoader

	def initialize(opts={})
		@data_provider = opts[:data_proviider] || DataProvider.new
	end

	def load(locations, time_period, visits)

		#visits.heatmaps = @data_provider.volume_querry(locations, time_period)
		#visits.volume_data = @data_provider.heat_map_querry(locations)

		locations.each do |location|
			time_period.days.each do |day|
				#daily_vol = visits.volume_data[location.to_sym]
				#visits.half_hr_visits[location.to_sym][day.to_s] = visits.heat_maps[location.to_sym][day.dow.to_s].map{ |percent| percent * daily_vol }
				visits.half_hr_visits[location.to_sym][day.to_s] = @data_provider.dummy_visits_querry
			end
		end

	end
end

