class VisitProjection < ActiveRecord::Base
  belongs_to :schedule
  belongs_to :location

  has_one :location_plan

		# visits  # visits data hashed by day
		# heat_maps = a Heatmap object
		# volumes = # patient volume data hashed by day
										#(currently only available per week, but client wants per day)

  # Fills in the "visits" field based on data in volumes & heat_maps
  validates :visits, presence: true
  validate :valid_volumes

  def valid_volumes
    unless volumes && !volumes.empty?
      errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
      return
    end
    volumes.each do |k, v|
      unless !v.nil? && v >= 0
        errors.add(:base, "Please add valid patient volume forecasts for this schedule.")
        return
      end
    end
  end


  def day_max(day)
    visits[day.to_s].max
  end

  def am_min(day)
    length = visits[day.to_s].length
    visits[day.to_s][0..(length/2 -1)].min
  end

  def pm_min(day)
    length = visits[day.to_s].length
    visits[day.to_s][(length/2)..-1].min
  end

  def sum
    visits.each_value.inject(0) { | total, v | total + v.sum }
  end

  def daily_avg
    sum / total_days
  end

  def week_avg
    daily_avg * 7
  end

  def total_days
    visits.size
  end

  def build_visits
    self.visits = {}

    schedule.days.each do |day|
      daily_vol = self.volumes[day.to_s]
      if source == :sample_run || source == :dummy_run
        self.visits[day.to_s] = heat_maps[day.wday].map{ |percent| percent * daily_vol }
      else
        self.visits[day.to_s] = heat_maps.build_day_volume(daily_vol, day, location)
      end
    end

  end

	def self.import!(data_provider, schedule, locations)
    all_volumes = data_provider.volume_query(locations, schedule)
    all_heat_maps = data_provider.heat_map_query(locations, schedule)

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
