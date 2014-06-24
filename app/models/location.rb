class Location < ActiveRecord::Base
  belongs_to :zone

  validates :zone, presence: true
  validates :rooms, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, numericality: { greater_than: 0, less_than: 100 }

  scope :ordered, -> { order(name: :asc) }

  default_scope -> { order(name: :asc) }


  DAYS = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end

  def coverage_options(day)
    CoverageOptions.new(open: @_open_times[day.wday()], close: @_close_times[day.wday()], max_mds: @max_mds)
  end

  # For compatibility with shifty Location
  def open_times=(ary)
    @_open_times = ary

    DAYS.each_with_index do |day, i|
      send("#{day}_open=", ary[i]) if ary[i]
    end
  end

  def close_times=(ary)
    @_close_times = ary

    DAYS.each_with_index do |day, i|
      send("#{day}_close=", ary[i]) if ary[i]
    end
  end

  # TODO: Currently only works when set with open_times
  def open_times
    @_open_times
  end

  # TODO: Currently only works when set with open_times
  def close_times
    @_close_times
  end
end
