require 'csv'

class DataProvider

  attr_reader :source

	def initialize(source)
		@source = source
	end

	def volume_querry(locations, schedule)
		self.send("read_and_parse_#{@source}_volume_data".to_sym, locations, schedule)
	end

	def heat_map_querry(locations, schedule)
		heat_maps = Hash.new
		locations.each do |location|
			heat_maps[location.report_server_id] = self.send("read_and_parse_#{@source}_heat_map".to_sym, location, schedule)
		end
		heat_maps
	end

	private

		def read_and_parse_sample_run_volume_data(locations, schedule)
			table = CSV.table("mock_data/sample_run/volume_data_short.csv")

			vol = Hash.new{ |hash, key| hash[key] = Hash.new }

			locations.each do |location|
				e = schedule.days.each
				table.each do |row|
						weekly_vol = row.field(location.report_server_id.downcase.to_sym)
						7.times { vol[location.report_server_id][e.next.to_s] = weekly_vol }
				end
			end

			vol
		end

		def read_and_parse_dummy_volume_data(locations, schedule)
			col = CSV.table("mock_data/dummy/visits.csv").by_col[0]

			vol = Hash.new{ |hash, key| hash[key] = Hash.new }

			locations.each do |location|
				schedule.days.each do |day|
					vol[location.report_server_id][day.to_s] = col.inject{ |sum, n| sum + n } * 7
				end
			end

			vol
		end

		def read_and_parse_sample_run_heat_map(location, schedule)
			table = CSV.table("mock_data/sample_run/#{location.name}_May_Heatmap.csv")

			heat_map = Array.new(8) { Array.new }

      table.each do |row|
        heat_map[0] << row.field(:sunday)/100
        heat_map[1] << row.field(:monday)/100
        heat_map[2] << row.field(:tuesday)/100
        heat_map[3] << row.field(:wednesday)/100
        heat_map[4] << row.field(:thursday)/100
        heat_map[5] << row.field(:friday)/100
        heat_map[6] << row.field(:saturday)/100
        heat_map[7] << row.field(:hour)[0..1].to_i + row.field(:hour)[3..4].to_f/60
      end

      scrub_heat_map(heat_map, location)
		end

		def read_and_parse_dummy_heat_map(location, schedule)
			col = CSV.table("mock_data/dummy/visits.csv").by_col[0]

			sum = col.inject{ |sum, n| sum + n }
			day_heat_map = col.map { |x| x.to_f / ( 7 * sum ) }
			heat_map = 	Array.new(7, day_heat_map)
			heat_map
		end

		def scrub_heat_map(heat_map, location)
      #puts heat_map.inspect
      for n in 0..6
        opening_time = location.open_times[n]
        closing_time = location.close_times[n]
        opening_index = (heat_map[7]).index(opening_time)
        closing_index = (heat_map[7]).index(closing_time - 0.5 )
        heat_map[n] = heat_map[n][opening_index..closing_index]
      end

			heat_map[0..6]
		end
end
