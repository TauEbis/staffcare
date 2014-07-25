class Heatmap < ActiveRecord::Base
  belongs_to :report_server_ingest

  def initialize(loc_name)
    @name = loc_name
    Date::DAYNAMES.each do |day|
      @days[day] = {}
    end
  end

  def set(day, hour, percentage)
    @days[day][hour] = percentage
  end

end

