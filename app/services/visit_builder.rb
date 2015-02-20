# Projects visits from heatmap/volume data from the CityMD report server.
# Should perhaps be more accurately named VisitBuilder or even VisitCombiner
class VisitBuilder

  def build_projection!(location, schedule, volume_source)
    volume_source = verify_source(location, schedule, volume_source)

    heatmap = heatmap_query(location)
    volumes = volume_query(location, schedule, volume_source)
    days = schedule.days.first..schedule.days.last # Not presently used


    projection = VisitProjection.create(
      volume_source: volume_source,
      schedule: schedule,
      location: location,
      volumes: volumes,
      heatmap: heatmap.shear_to_opening_hours,
      visits: build_visits(volumes, heatmap, volume_source)
    )

    projection
  end

  # Returns the projected visits by combining the volume data and the heatmap
  def build_visits(volumes, heatmap, volume_source, opts={})
    visits = {}
    start_date = Date.parse(volumes.keys.sort.first.to_s)
    end_date = Date.parse(volumes.keys.sort.last.to_s)

    case volume_source

      when :patient_volume_forecasts
      sheared_heatmap = heatmap.shear_to_opening_hours

      (start_date..end_date).each do |date|
        weekly_vol = volumes[date.to_s]
        percents = sheared_heatmap[Date::DAYNAMES[date.wday]].values
        visits[date.to_s] = percents.map{ |percent| percent * weekly_vol }
      end

      when :volume_forecaster
      chunks = volumes.values.first.size
      chunked_heatmap = heatmap.in_normalized_chunks(chunks)

      (start_date..end_date).each do |date|
        visits[date.to_s] = {}

        (0..chunks-1).each do |chunk|
          chunk_vol = volumes[date][chunk]
          chunked_visits_hash = {}

          chunked_heatmap[date.wday][chunk].each { |k,v| chunked_visits_hash[k] = v * chunk_vol }
          visits[date.to_s].merge! chunked_visits_hash
        end
        visits[date.to_s] = visits[date.to_s].values unless opts[:keep_times] # ShortForecast expects visits to be hashed by time and date. Optimizer expects an array of visits hashed by date.
      end
    end

    visits
  end


  private

    # Returns heatmaps as a two level day, hour hash
    def heatmap_query(location)
      if heatmap = Heatmap.find_by(location_id: location.id)
      else
        raise StandardError, "No heatmap exists on report server for #{location.name}"
      end
      heatmap
    end

    # Returns patient volume projection as a hash of the day
  	def volume_query(location, schedule, volume_source, forecaster = nil)
      vol = {}

      case volume_source
        when :patient_volume_forecasts
        schedule.days.each do |day|
          unless vol[day.to_s] = PatientVolumeForecast.get_weekly_volume(location, day)
            raise StandardError, "No volume data exists for #{location.name} on #{day}"
          end
        end
        when :volume_forecaster
        forecaster ||= create_forecaster_for(location, schedule)
        unless vol = forecaster.full_forecast(schedule.days.first, schedule.days.last)
          raise StandardError, "Not enough data to build a forecaster for #{location.name} starting on #{schedule.days.ordered.first}"
        end
      end

      vol
  	end

    def create_forecaster_for(location, schedule)
      date_range = forecaster_data_date_range(schedule)
      VolumeForecaster.new(date_range, location)
    end

    def verify_source(location, schedule, volume_source)
      if volume_source == :volume_forecaster
        date_range = forecaster_data_date_range(schedule)
        volume_source = location.has_visits_data(date_range) ? :volume_forecaster : :patient_volume_forecasts
      end
      volume_source
    end

    def forecaster_data_date_range(schedule)
      lookback_window = 10 # weeks of data for VolumeForecaster to consider
      VolumeForecaster.calc_data_date_range(lookback_window, schedule.days.first)
    end

  end