class Visits

attr_accessor :half_hr_visits, :heat_maps, :volume_data

	def initialize
		@half_hr_visits = Hash.new{ |hash, key| hash[key] = Hash.new } # visits data hashed by location, day
		@heat_maps = Hash.new{ Array(7) } #  hash by location of arrays (day of week index) of half_hourly percentages
		@volume_data = Hash.new{ |hash, key| hash[key] = Hash.new } # patient volume data hashed by location, day
																																#(currently only available per week, but client wants per day)
	end

	def build_for(locations, time_period)
		VisitsLoader.new.load(locations, time_period, self)
		@time_stamp=Time.now
		self
	end

end