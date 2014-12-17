class Heatmap < ActiveRecord::Base
  validates :days, presence:true
  validates :uid, presence:true

  belongs_to :location, primary_key: :uid, foreign_key: :uid
  belongs_to :report_server_ingest

  scope :ordered, -> { joins(:location).order('locations.name ASC') }

      self.days[day] = {}
    end
  end

# this shouldn't be in the heatmap
  def build_day_volume(total_volume, day)
    percents = days[Date::DAYNAMES[day.wday]].values

    start_time = location.open_times[day.wday]
    end_time   = location.close_times[day.wday]

    # Assuming percents is always 28 starting at 8am
    start_index = (start_time - 8) * 2
    end_index   = (end_time - 8) * 2

    percents[start_index...end_index].map{ |percent| percent * total_volume }
  end

end

