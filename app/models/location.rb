# A location record in the database- see LocationPlan for a record of how
# a location was configured when a schedule was generated.
class Location < ActiveRecord::Base
  belongs_to :zone

  has_one :heatmap
  has_many :memberships
  has_many :users, through: :memberships
  has_many :speeds, dependent: :destroy, inverse_of: :location
  has_many :visits, dependent: :destroy
  accepts_nested_attributes_for :speeds, reject_if: proc { |attributes| attributes['doctors'].blank? }

  validates :name, presence: true
  #validates :uid, presence: true # This only alllows creating new locations via reportserver
  validates :zone, presence: true
  validates :upload_id, uniqueness: true, presence: true
  validates :rooms, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :managers, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 1 }
  validates :assistant_managers, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 2 }

  # could likely be removed since min_openers/min_closers
  # seem not be used but rather calculated on the location_plan
  # and just set to 1 by default by the database
  validates :min_openers, :min_closers, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_mds }, unless: "max_mds.nil?"
  validate :validate_nested_speeds_sequence

  scope :ordered, -> { order(name: :asc) }
  scope :assigned, -> { where( zone_id: Zone.assigned.pluck(:id) ) }
  scope :for_schedule, -> (schedule) { where(id: schedule.locations) }

  # Removed because it interferes with distinct
  #default_scope -> { order(name: :asc) }


  DAYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end

  DAY_PARAMS.each do |day_param|
    validates day_param, presence: true, numericality: { greater_than_or_equal_to: 480, less_than_or_equal_to: 1320,
                                                          message: "Opening hours must be between 8AM and 10PM" }
  end

  DAYS.each do |day|
    validates "#{day}_close".to_sym, numericality: { greater_than_or_equal_to: ->(location) { location.send("#{day}_open".to_sym) + 360 },
                                                     message: "Closing time must be at least 6 hours after opening time"}, unless: "send(\"#{day}_open\").nil?"
  end

  def ftes
    managers + assistant_managers
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
    @_close_times ||= DAYS.map {|day| send("#{day}_close") / 60 }
  end

  def manager
    users.each do |user|
      return user if user.manager?
    end
    nil
  end

  def rm
    users.each do |user|
      return user if user.rm?
    end
    nil
  end

  def validate_nested_speeds_sequence
    doctor_set = speeds.map(&:doctors).sort
    max = doctor_set.length

    if doctor_set.empty?
      errors.add(:base, "Must have at least one work rate")
    elsif doctor_set.uniq.length != max
      errors.add(:base, "Physician numbers must be unique")
    elsif doctor_set != (1..max).to_a
      errors.add(:base, "Physician numbers must be sequential")
    end
  end

  # Used to calcluate date range for ReportServerFactory#scheduled_import!

  def self.date_of_first_missing_visit
    suspects = ordered.map(&:first_missing_visit_date).compact
    !suspects.empty? ? suspects.sort.first : nil
  end

  def first_missing_visit_date
    if visits.empty?
      return nil
    elsif !consecutive_visits?
      return first_missing_consecutive_visit_date
    else
      return visits.ordered.last.date + 1.days
    end
  end

  def consecutive_visits?
    (visits.ordered.first.date..visits.ordered.last.date).to_a.size == visits.size
  end

  def first_missing_consecutive_visit_date
    missing_dates = (visits.ordered.first.date..visits.ordered.last.date).to_a - visits.ordered.pluck(:date)
    missing_dates.each do |date|
      return date unless (date.day == 25 && date.month == 12) # Xmas doesn't count
    end
    return nil
  end

  # Used to calculate heatmaps for location

  def average_timeslot_volumes # hashed by day of week and time
    avg_visits = {}
    (0..6).each do |day_of_week|
      day_of_week_visits = visits.where(dow: day_of_week)
      total_days = day_of_week_visits.size
      summed_visits = day_of_week_visits.map(&:volumes).inject do | h1, h2 |
        h1.merge(h2){ |key, oldval, newval| oldval + newval }
      end
      avg_visits[Date::DAYNAMES[day_of_week]] = summed_visits.each{ |k,v| summed_visits[k] = v/total_days }
    end
    avg_visits
  end

  def sufficient_data_for_heatmap?
    (0..6).each do |day_of_week|
      total_days = visits.where(dow: day_of_week).size
      return false if total_days < 1
    end
    true
  end

# Used by ShortForecast and VisitBuilder to verify if the VolumeForecaster can be used
  def has_visits_data(date_range)
    visits.for_date_range(date_range).size == date_range.to_a.size
  end

  # Used by ReportServerIngestor
  def self.create_default(name, passed_attributes={})
    attr = { name: name, upload_id: name.gsub(' ', '_'), max_mds: 3, rooms: 12,
             open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]
            }.merge(passed_attributes)

    z0 = Zone.where(name: 'Unassigned').first_or_initialize
    location = z0.locations.build(attr)

    location.speeds.build(doctors: 1, normal: 4, max: 6)
    location.speeds.build(doctors: 2, normal: 8, max: 12)
    location.speeds.build(doctors: 3, normal: 12, max: 18)
    location.speeds.build(doctors: 4, normal: 16, max: 24)
    location.speeds.build(doctors: 5, normal: 20, max: 30)

    location.save!
  end

end