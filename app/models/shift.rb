class Shift < ActiveRecord::Base
  # Potentially a shift could exist in a timezone that is not the TZ that the "current" user thread is in
  # For now we hard-code that all shifts happen in Eastern TZ
  # This only matters when trying to determine what "Day" a shift is on or what "hour" of the day it starts
  TZ = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

  belongs_to :grade

  scope :for_day, ->(day) { where(starts_at: day.in_time_zone.beginning_of_day..day.in_time_zone.end_of_day) }

  def starts_hour
    @_starts_hour ||= starts_at.in_time_zone(TZ).hour
  end

  def ends_hour
    @_ends_hour   ||= ends_at.in_time_zone(TZ).hour
  end

  def to_knockout
    {id: id, starts_hour: starts_hour, ends_hour: ends_hour}
  end
end
