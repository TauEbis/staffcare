class VisitsProjector

	def project(locations, time_period, data_provider, projection)

		projection.volume_data = data_provider.volume_querry(locations, time_period)
		projection.heat_maps = data_provider.heat_map_querry(locations, time_period)

		locations.each do |location|
			time_period.days.each do |day|
				daily_vol = projection.volume_data[location.to_sym][day.to_s]
				projection.visits[location.to_sym][day.to_s] = projection.heat_maps[location.to_sym][day.wday].map{ |percent| percent * daily_vol }
			end
		end

	end
end

