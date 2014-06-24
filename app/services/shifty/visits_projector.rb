class VisitsProjector

	def project(locations, schedule, data_provider, projection)

		projection.volume_data = data_provider.volume_querry(locations, schedule)
		projection.heat_maps = data_provider.heat_map_querry(locations, schedule)

		locations.each do |location|
			schedule.days.each do |day|
				daily_vol = projection.volume_data[location.to_sym][day.to_s]
				projection.visits[location.to_sym][day.to_s] = projection.heat_maps[location.to_sym][day.wday].map{ |percent| percent * daily_vol }
			end
		end

	end
end

