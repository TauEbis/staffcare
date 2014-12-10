require 'date'
require 'time'

# Record for a single location for the given time period- not an ActiveRecord model, just
# used as an intermediate form for calculating heatmaps.
class IngestRecord

  attr_accessor :name, :uid, :total_visits, :days

  def initialize(loc, uid)
    @name = loc
    @uid = uid
    @total_visits = 0.0

    @days = {}
    Date::DAYNAMES.each do |day|
      @days[day] = {}
    end
  end

  def add_block(dow, hour, count)
    @days[Date::DAYNAMES[dow.to_i]][hour] = count.to_f
    @total_visits += count
  end

end
