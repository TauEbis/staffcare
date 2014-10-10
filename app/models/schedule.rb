# A generated and scored schedule
class Schedule < ActiveRecord::Base

  has_many :visit_projections, dependent: :destroy # is this used anywhere?
  has_many :location_plans, dependent: :destroy

  enum state: [ :draft, :active, :locked, :archived ]

  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
  scope :ordered, -> { order(starts_on: :desc, updated_at: :desc) }
  scope :has_deadlines, -> { where("manager_deadline is not NULL AND gm_deadline is not NULL AND sync_deadline is not NULL") }

  default_scope -> { order(starts_on: :desc, updated_at: :desc) }

  OPTIMIZER_FIELDS = [:penalty_30min, :penalty_60min, :penalty_90min, :penalty_eod_unseen, :penalty_turbo, :penalty_slack, :oren_shift]

# Will remove Oren shift shortly
  (OPTIMIZER_FIELDS-[:oren_shift]).each do |field|
    validates field, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 5000 }
  end

  INTERVAL_GRANULARITY = 5

  validates :starts_on, presence: true
  validate :valid_starts_on
  validates_associated :location_plans


  def valid_starts_on
    unless starts_on.is_a? Date
      errors.add(:starts_on, "Please select a starting date.")
      return
    end

    unless starts_on.mday == 1
      errors.add(:starts_on, "Schedule must start on first day of the month.")
    end
  end


  def self.default_attributes
    {
      penalty_30min: 10,
      penalty_60min: 100,
      penalty_90min: 300,
      penalty_eod_unseen: 40,
      penalty_turbo: 60,
      penalty_slack: 180,
      oren_shift: true
    }
  end

  def length
    @_length ||= (ends_on - starts_on + 1).to_i
  end

  def ends_on
    @_ends_on ||= starts_on.end_of_month
  end

  def custom_length(length) # Method for faster testing
    @_length = length
    @_ends_on = starts_on + length
  end

  def days
    @_days ||= (starts_on..ends_on).to_a
  end

  def grader_weights
    @_grader_weights ||= self.attributes.slice(*OPTIMIZER_FIELDS.map(&:to_s)).symbolize_keys
  end

  def unoptimized_summed_points(zone = nil)
    @_points ||= {}
    @_points[zone] ||= begin
      lp = zone ? location_plans.for_zone(zone).includes(:chosen_grade) : location_plans.includes(:chosen_grade)
      Grade.unoptimized_sum(lp.map(&:chosen_grade))
    end
  end

  def letters(zone = nil)
    @_letters ||= {}
    @_letters[zone] ||= begin
      lp = zone ? location_plans.for_zone(zone).includes(:chosen_grade) : location_plans.includes(:chosen_grade)
      Grade.month_letters(lp.map(&:chosen_grade))
    end
  end

  def stats(zone = nil)
    @_stats ||= {}
    @_stats[zone] ||= begin
      lp = zone ? location_plans.for_zone(zone).includes(:chosen_grade) : location_plans.includes(:chosen_grade)
      Grade.unoptimized_stats(lp.map(&:chosen_grade))
    end
  end

  def any_updates?
    check_for_updates.values.include? true
  end

  def check_for_updates
    new_heatmaps, new_forecasts, new_locations = false, false, false

    forecasts = PatientVolumeForecast.where(start_date: ((starts_on-6)..ends_on) )
    forecasts_updates = forecasts.map(&:updated_at).max
    location_plans.each do |lp|
      new_locations = true if lp.updated_at < lp.location.updated_at
      new_heatmaps = true if lp.visit_projection.updated_at < Heatmap.find_by!(uid: lp.location.uid).updated_at
      new_forecasts = true if lp.visit_projection.updated_at < forecasts_updates
    end

    {heatmaps: new_heatmaps, forecasts: new_forecasts, location: new_locations}
  end

  def locations
    location_plans.map(&:location).uniq
  end

  def zones
    locations.map(&:zone).uniq
  end
end
