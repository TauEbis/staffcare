class Shift < ActiveRecord::Base
  # Potentially a shift could exist in a timezone that is not the TZ that the "current" user thread is in
  # For now we hard-code that all shifts happen in Eastern TZ
  # This only matters when trying to determine what "Day" a shift is on or what "hour" of the day it starts
  TZ = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

  belongs_to :grade

  scope :for_day, ->(day) { where(starts_at: day.in_time_zone.beginning_of_day..day.in_time_zone.end_of_day) }

  enum position: [:md, :scribe, :pcr, :ma, :xray, :manager, :am]

  scope :not_md, -> { where.not(position: Shift.positions[:md])}

  LINE_WORKERS = {
    scribe: 'Scribe',
    pcr: 'PCR',
    ma: 'MA',
    xray: 'X-Ray',
    manager: 'Manager',
    am: 'Asst Manager'
  }.freeze

  def starts_hour
    @_starts_hour ||= starts_at.in_time_zone(TZ).hour
  end

  def ends_hour
    @_ends_hour   ||= ends_at.in_time_zone(TZ).hour
  end

  def date
    @_date        ||= starts_at.in_time_zone(TZ).to_date
  end

  def to_knockout
    {id: id, starts_hour: starts_hour, ends_hour: ends_hour, date: date}
  end

  # Takes a date object for the day
  # and a start & end integer number of hours to offset from midnight that day
  def from_start_end_times(date, starts, ends)
    _date = date.in_time_zone(TZ)
    self.starts_at = _date.change(hours: starts)
    self.ends_at   = _date.change(hours: ends)
    self
  end

  def from_knockout(date, params)
    from_start_end_times(
      date,
      params['starts'],
      params['ends']
    )
  end

  def wiw_shift
    if wiw_id
      Wiw::Shift.find(wiw_id)
    end
  end
end
