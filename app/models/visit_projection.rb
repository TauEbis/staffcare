class VisitProjection < ActiveRecord::Base
  belongs_to :location

	def initialize(data_provider)
		# visits  # visits data hashed by day
		# heat_maps = Array.new(7,Array.new)) #  eg. heat_maps[day_of_week_as_int] is an Array of half hourly percentages
		# volume_data = # patient volume data hashed by day
										#(currently only available per week, but client wants per day)
		@data_provider = data_provider
		@time_stamp = Time.now
	end

	def self.import!(data_provider, schedule)
    Location.all.each do |location|
      projection = VisitProject.build()
      projection.volume_data = data_provider.volume_querry(locations, schedule)
      projection.heat_maps = data_provider.heat_map_querry(locations, schedule)

      schedule.days.each do |day|
        id = location.report_server_id
        daily_vol = projection.volume_data[id][day.to_s]
        projection.visits[id][day.to_s] = projection.heat_maps[id][day.wday].map{ |percent| percent * daily_vol }
      end
    end
  end

end
