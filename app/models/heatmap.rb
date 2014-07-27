class Heatmap < ActiveRecord::Base
  validates :days, presence:true
  validates :uid, presence:true

  serialize :days, Hash

  belongs_to :location

  def set(day, hour, percentage)
    if !self.days.has_key? day
      self.days[day] = {}
    end
    self.days[day][hour] = percentage
  end

  def get_days
    return self.days
  end

end

