class Heatmap < ActiveRecord::Base
  validates :days, presence:true
  validates :uid, presence:true

  serialize :days, Hash

  belongs_to :location, foreign_key: :uid

  def set(day, hour, percentage)
    if !self.days.has_key? day
      self.days[day] = {}
    end
    self.days[day][hour] = percentage
  end

  def get_days
    return self.days
  end

  def build_day_volume(total_volume, day, location)
    percents = self.days[Date::DAYNAMES[day.wday]].values

    start_time = location.open_times[day.wday]
    end_time   = location.close_times[day.wday]

    # Assuming percents is always 28 starting at 8am
    start_index = (start_time - 8) * 2
    end_index   = (end_time - 8) * 2

    percents[start_index...end_index].map{ |percent| percent * total_volume }
  end


end

