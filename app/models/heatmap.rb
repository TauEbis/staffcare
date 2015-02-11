class Heatmap < ActiveRecord::Base
  validates :days, presence:true

  belongs_to :location
  belongs_to :report_server_ingest

  scope :ordered, -> { joins(:location).order('locations.name ASC') }

  # volumes  comes in as: { day1 => { time1 => quarter_hourly_volume1 }, day2 => ... }
  def recalc_from_volumes(volumes, granularity=30)
    days_will_change!
    total = volumes.values.flat_map(&:values).sum # total visit
    volumes.keys.each do |day|
      self.days[day] = {}
      volumes[day].keys.sort.each_slice(2) do |time1, time2|    # time is assumed to be in 15 minute intervals
        self.days[day][time1] = volumes[day][time1] / total
        if granularity == 30
          self.days[day][time1] += volumes[day][time2] / total
        elsif granularity == 15
          self.days[day][time2] = volumes[day][time2] / total
        end
      end
    end
    save!
  end

  def shear_to_opening_hours
    open_times, close_times = location.open_times, location.close_times
    sheared_heatmap = {}

    Date::DAYNAMES.each_with_index do |day_name, day_index|
      start_hour = open_times[day_index]
      end_hour   = close_times[day_index]

      start_to_s = Time.now.beginning_of_day.change(hour: start_hour).to_s(:time)
      end_to_s = Time.now.beginning_of_day.change(hour: end_hour).to_s(:time)

      sheared_heatmap[day_name] = days[day_name].select{ |k,v| start_to_s <= k && k < end_to_s } # string comparison
    end
    self.class.normalize!(sheared_heatmap)
  end

  def in_normalized_chunks(chunks)
    normalized_chunks=[]
    (0..6).each do |wday|
      normalized_chunks[wday] = []

      day_hash = shear_to_opening_hours[Date::DAYNAMES[wday]]
      num_of_keys = day_hash.keys.size
      step = num_of_keys / chunks

      (0...chunks).each do |chunk|
        chunk_keys = day_hash.keys[(chunk*step..chunk*step+step-1)]
        chunk_keys = day_hash.keys[(chunk*step..-1)] if chunk == chunks-1
        heatmap_chunk = day_hash.select{ |k,v| chunk_keys.include?(k) }
        chunk_total = heatmap_chunk.values.sum
        normalized_chunks[wday][chunk] = heatmap_chunk.each { |k,v| heatmap_chunk[k] = v/chunk_total }
      end
    end
    normalized_chunks
  end

# Used to normalize sheared heatmaps so that they sum to 100%
  def self.normalize!(sheared_heatmap)
    total = sheared_heatmap.values.map(&:values).map(&:sum).sum

    Date::DAYNAMES.each do |day_name|
      sheared_heatmap[day_name].each{ |k,v| sheared_heatmap[day_name][k] = v/total } # normalize
    end

    sheared_heatmap
  end

end

