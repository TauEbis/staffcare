require 'date'
require 'time'

# Record for a single location for the given time period- not an ActiveRecord model, just
# used as an intermediate form for calculating heatmaps.
class IngestRecord 

  attr_accessor :name, :total_visits, :uid

  def initialize(loc, uid)
    @name = loc
    @uid = uid
    @days = {}
    @total_visits = 0.0
    Date::DAYNAMES.each do |day|
      @days[day] = {}
    end
  end

  def add_block(dow, hour, count)
    @days[Date::DAYNAMES[dow.to_i]][hour] = count.to_f
    @total_visits += count
  end

  def get_day(dayname)
    return @days[dayname]
  end

  def get_visits(day, hour)
    return @days[day][hour]
  end

end
