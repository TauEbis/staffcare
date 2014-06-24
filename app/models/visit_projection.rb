class VisitProjection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :location

  has_one :location_plan

		# visits  # visits data hashed by day
		# heat_maps = Array.new(7,Array.new)) #  eg. heat_maps[day_of_week_as_int] is an Array of half hourly percentages
		# volumes = # patient volume data hashed by day
										#(currently only available per week, but client wants per day)

  # Fills in the "visits" field based on data in volumes & heat_maps
  def build_visits
    self.visits = {}

    schedule.days.each do |day|
      daily_vol = volumes[day.to_s]
      self.visits[day.to_s] = heat_maps[day.wday].map{ |percent| percent * daily_vol }
    end
  end

	def self.import!(data_provider, schedule, locations)
    all_volumes = data_provider.volume_querry(locations, schedule)
    all_heat_maps = data_provider.heat_map_querry(locations, schedule)

    projections = {}

    locations.each do |location|
      rsid = location.report_server_id

      projection = VisitProjection.new(
        source: data_provider.source,
        schedule: schedule,
        location: location,
        volumes: all_volumes[rsid],
        heat_maps: all_heat_maps[rsid]
      )

      projection.build_visits

      projection.save!

      projections[rsid] = projection
    end

    projections
  end

end
