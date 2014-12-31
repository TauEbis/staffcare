# Projects visits from heatmap/volume data from the CityMD report server.
class VisitProjector

  def project!(location, schedule, volume_source)
    volumes = volume_query(location, schedule, volume_source)
    heatmap = heatmap_query(location)

    projection = VisitProjection.create(
      source: volume_source,
      schedule: schedule,
      location: location,
      volumes: volumes,
      heatmap: heatmap,
      visits: build_visits(schedule, volumes, heatmap)
    )

    projection
  end

  private
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

    # Returns heatmaps as a two level day, hour hash
  	def heatmap_query(location)
      if heatmap = Heatmap.find_by(location_id: location.id)
        heatmap.shear_to_opening_hours
      else
        raise StandardError, "No heatmap exists on report server for #{location.name}"
      end
  	end

    # Returns the projected visits by combining the weekly volume data and the heatmap
    def build_visits(schedule, volumes, heatmap)
      visits = {}

      schedule.days.each do |day|
        weekly_vol = volumes[day.to_s]
        percents = heatmap[Date::DAYNAMES[day.wday]].values
        visits[day.to_s] = percents.map{ |percent| percent * weekly_vol }
      end
      visits
    end

  end