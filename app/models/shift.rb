class Shift < ActiveRecord::Base
  # Potentially a shift could exist in a timezone that is not the TZ that the "current" user thread is in
  # For now we hard-code that all shifts happen in Eastern TZ
  # This only matters when trying to determine what "Day" a shift is on or what "hour" of the day it starts
  TZ = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

  belongs_to :grade
  belongs_to :position

  validates :position, presence: true

  scope :for_day, ->(day) { where(starts_at: day.in_time_zone.beginning_of_day..day.in_time_zone.end_of_day) }

  scope :md, -> { where( position: Position.where(key: :md) ) }
  scope :not_md, -> { where.not( position: Position.where(key: :md) ) } # nil position keys include
  scope :line_workers, -> { where.not( position: Position.where(key: [:md, nil] ) ) } # nil positions keys not included

  scope :am, -> { where( position: Position.where(key: :am) ) }
  scope :ma, -> { where( position: Position.where(key: :ma) ) }
  scope :manager, -> { where( position: Position.where(key: :manager) ) }
  scope :pcr, -> { where( position: Position.where(key: :pcr) ) }
  scope :scribe, -> { where( position: Position.where(key: :scribe) ) }
  scope :xray, -> { where( position: Position.where(key: :xray) ) }

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
    {id: id, starts_hour: starts_hour, ends_hour: ends_hour, date: date, position_key: position.key}
  end

  # Takes a date object for the day
  # and a start & end integer number of hours to offset from midnight that day
  def from_start_end_times(date, starts, ends, position_key)
    _date = date.in_time_zone(TZ)
    self.starts_at = _date.change(hour: starts)
    self.ends_at   = _date.change(hour: ends)
    self.position = Position.find_by(key: position_key)
    self
  end

  def from_knockout(date, params)
    from_start_end_times(
      date,
      params['starts'],
      params['ends'],
      params['position_key']
    )
  end

  def wiw_shift
    if wiw_id
      Wiw::Shift.find(wiw_id)
    end
  end
end
