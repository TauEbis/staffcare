# Projects visits from heatmap/volume data from the CityMD report server.
class VisitProjector

  def project!(location, schedule, volume_source)
    volumes = volume_query(location, schedule, volume_source)
    heat_map = heat_map_query(location)

    projection = VisitProjection.create(
      source: volume_source,
      schedule: schedule,
      location: location,
      volumes: volumes,
      heat_maps: heat_map  # Make Singular?
      visits: build_visits(volumes, heatmap)
    )

    projection
  end

  # Returns patient volume projection as a hash of the day
	def volume_query(location, schedule, volume_source)
    vol = {}

    case volume_source
      when :patient_volume_forecasts
      schedule.days.each do |day|
        unless vol[day.to_s] = PatientVolumeForecast.get_weekly_volume(location, day)
          raise StandardError, "No volume data exists for #{location.name} on #{day}"
        end
      end
    end

    vol
	end

  # Returns heatmaps as a two level day, hour hash and shears/normalizes the heatmasp data
	def heat_map_query(location)
    unless heat_map = Heatmap.find_by(uid: location.uid)
      raise StandardError, "No heatmap exists on report server for #{location.name}"
    end

    sheared_heatmap = shear_heatmap(heatmap, location.open_times, location.close_times)
    normalized_sheared_heatmap = normalize_heatmap(sheared_heatmap)
    normalized_sheared_heatmap
	end

  # Returns the projected visits by combinging the weekly volume data and the heatmap
  def build_visits(volumes, heatmap)
    visits = {}

    schedule.days.each do |day|
      weekly_vol = volumes[day.to_s]
      percents = heatmap[Date::DAYNAMES[day.wday]].values
      visits[day.to_s] = percents.map{ |percent| percent * weekly_vol }
    end

  end

	private

    def shear_heatmap(heatmap, open_times, close_times)
      sheared_heatmap = {}

      Date::DAYNAMES.each_with_index do |day_name, day_index|
        start_time = open_times[day_index]
        end_time   = close_times[day_index]

        # Assuming heatmap#days is always 28 starting at 8am
        start_index = (start_time - 8) * 2
        end_index   = (end_time - 8) * 2

        sheared_heatmap[day_name] = heatmap.days[day_name].keep_if{ |k,v| (start_index...end_index).include?(key) }
      end

      sheared_heatmap
    end

    def normalize_heatmap(sheared_heatmap)
      total = sheared_heatmap.values.map(&:values).map(&:sum).sum

      Date::DAYNAMES.each do |day_name|
        sheared_heatmap[day_name].each{ |k,v| sheared_heatmap[day_name][k] = v/total } # normalize
      end

      sheared_heatmap
    end

end

