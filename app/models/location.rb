# A location record in the database- see LocationPlan for a record of how
# a location was configured when a schedule was generated.
class Location < ActiveRecord::Base
  belongs_to :zone

  validates :zone, presence: true
  validates :rooms, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, numericality: { greater_than: 0, less_than: 100 }

  scope :ordered, -> { order(name: :asc) }

  default_scope -> { order(name: :asc) }


  DAYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end

  # For compatibility with shifty Location
  def open_times=(ary)
    @_open_times = ary

    DAYS.each_with_index do |day, i|
      send("#{day}_open=", ary[i] * 60) if ary[i]
    end
  end

  def close_times=(ary)
    @_close_times = ary

    DAYS.each_with_index do |day, i|
      send("#{day}_close=", ary[i] * 60) if ary[i]
    end
  end

  def open_times
    @_open_times ||= DAYS.map {|day| send("#{day}_open") / 60 }
  end

  def close_times
    @_close_times ||= DAYS.map {|day| send("#{day}_open") / 60 }
  end
end
