# A location record in the database- see LocationPlan for a record of how
# a location was configured when a schedule was generated.
class Location < ActiveRecord::Base
  belongs_to :zone

  has_one :heatmap
  has_many :memberships
  has_many :users, through: :memberships
  has_many :speeds, dependent: :destroy, inverse_of: :location
  accepts_nested_attributes_for :speeds, reject_if: proc { |attributes| attributes['doctors'].blank? }

  validates :name, presence: true
  validates :uid, presence: true
  validates :zone, presence: true
  validates :rooms, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :min_openers, :min_closers, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: :max_mds }, unless: "max_mds.nil?"
  validate :validate_nested_speeds_sequence

  scope :ordered, -> { order(name: :asc) }
  scope :assigned, -> { where( zone_id: Zone.assigned.pluck(:id) ) }

  # Removed because it interferes with distinct
  #default_scope -> { order(name: :asc) }


  DAYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
  # [:mon_open, :mon_close, :tue_open, ...]
  DAY_PARAMS = DAYS.inject([]) do |acc, day|
    ['open', 'close'].each {|tod| acc << "#{day}_#{tod}".to_sym }
    acc
  end

  DAY_PARAMS.each do |day_param|
    validates day_param, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1440 }
  end

  DAYS.each do |day|
    validates "#{day}_close".to_sym, numericality: { greater_than_or_equal_to: "#{day}_open".to_sym, message: "Closing time must be greater than opening time"}, unless: "send(\"#{day}_open\").nil?"
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

end
