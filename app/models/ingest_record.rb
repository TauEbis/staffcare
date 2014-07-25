require 'date'
require 'time'

# Record for a single location for the given time period
class IngestRecord < ActiveRecord::Base
  belongs_to :report_server_ingest

  def initialize(location_name)
    @name = location_name
    @days = {}
    @total_visits = 0.0
    Date::DAYNAMES.each do |day|
      @days[day] = {}
    end
  end

  def add_block(dow, hour, count)
    @days[Date::DAYNAMES[dow.to_i]][Time.parse(hour)] = count.to_f
    @total_visits += count
  end

  def get_day(dayname)
    return @days[dayname]
  end

  def get_visits(day, hour)
    return @days[day][hour]
  end

end
