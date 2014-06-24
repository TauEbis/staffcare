class VisitsProjection

attr_accessor :visits, :heat_maps, :volume_data
attr_reader :time_stamp

	def initialize(data_provider)
		@visits = Hash.new{ |hash, key| hash[key] = Hash.new } # visits data hashed by location, day
		@heat_maps = Hash.new(Array.new(7,Array.new)) #  eg. heat_maps[location_name][day_of_week_as_int] is an Array of half hourly percentages
		@volume_data = Hash.new{ |hash, key| hash[key] = Hash.new } # patient volume data hashed by location, day
																																#(currently only available per week, but client wants per day)
		@data_provider = data_provider
		@time_stamp = Time.now
	end

	def project_for(locations, schedule)
		VisitsProjector.new.project(locations, schedule, @data_provider, self)
		@time_stamp = Time.now
		self
	end

end
