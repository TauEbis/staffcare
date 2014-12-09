require 'csv'

# Wraps data representing visit/volume data from the CityMD report server.
class DataProvider

  attr_reader :source

	def initialize(source)
		@source = source
	end

  # Returns patient volume projections as a two-level (location, day) hash
	def volume_query(locations, schedule)
    if @source == 'database'
      return get_volume_data(locations, schedule)
    end
	end

	def heat_map_query(locations, schedule)
    if @source == 'database'
      heat_maps = {}
      locations.each do |location|

        begin
          map = Heatmap.find_by!(uid: location.uid)
          heat_maps[location.report_server_id] = map
        rescue ActiveRecord::RecordNotFound => e
          raise StandardError, "No heatmap exists on report server for #{location.name}"
        end

      end
    end

		return heat_maps
	end

	private

    def get_volume_data(locations, schedule)
			vol = Hash.new{ |hash, key| hash[key] = Hash.new }
      forecasts = PatientVolumeForecast.ordered

      locations.each do |location|
           schedule.days.each do |day|
                found_it = false
                forecasts.each do |forecast|
                     if forecast.contains_day? day and forecast.contains_location? location
                          vol[location.report_server_id][day.to_s] =
                                   forecast.get_volume(location, day.to_s)
                          found_it = true
                     end
                end
                if !found_it
                  raise StandardError, "No volume data exists for #{location.name} on #{day}"
                end
           end
      end
      return vol
    end

=begin
#might be useful to normailize heatmaps
		def scrub_heat_map(heat_map, location)
      for n in 0..6
        opening_time = location.open_times[n]
        closing_time = location.close_times[n]
        opening_index = (heat_map[7]).index(opening_time)
        closing_index = (heat_map[7]).index(closing_time - 0.5 )
        heat_map[n] = heat_map[n][opening_index..closing_index]
      end

			heat_map[0..6]
		end
=end
end

