class DataProvider

	def volume_querry(locations, time_period)
	end

	def heat_map_querry(locations)
		locations.each do |location|
			heatmaps[location.to_sym]
		end
	end

	def sample_run_data
		f = File.open('mock_data/sample_run/CityMD_14th_St_May_Heatmap.csv', "r")
		visits = f.read.split("\r")
		f.close
		visits.map { |x| x.to_f }
	end

	def read_heat_map(location)
		f = File.open("mock_data/sample_run/#{location.name}_May_Heatmap.csv", "r")
		visits = f.read.split("\r")
		f.close
		visits.map { |x| x.to_f }
	end

	def dummy_visits_querry
		f = File.open('mock_data/visits.csv', "r")
		visits = f.read.split("\r")
		f.close
		visits.map { |x| x.to_f }
	end

end