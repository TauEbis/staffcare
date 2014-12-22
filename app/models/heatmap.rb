class Heatmap < ActiveRecord::Base
  validates :days, presence:true
  validates :uid, presence:true

  belongs_to :location, primary_key: :uid, foreign_key: :uid
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

end

