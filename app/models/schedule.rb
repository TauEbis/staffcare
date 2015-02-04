# A generated and scored schedule
class Schedule < ActiveRecord::Base

  has_many :visit_projections, dependent: :destroy
  has_many :location_plans, dependent: :destroy
  has_many :grades, dependent: :destroy

  enum state: [ :draft, :active, :locked, :archived ]

  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  enum volume_source: [:patient_volume_forecasts, :volume_forecaster]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
  scope :ordered, -> { order(starts_on: :desc, updated_at: :desc) }
  scope :has_deadlines, -> { where("manager_deadline is not NULL AND rm_deadline is not NULL AND sync_deadline is not NULL") }

  default_scope -> { order(starts_on: :desc, updated_at: :desc) }

  OPTIMIZER_FIELDS = [:penalty_30min, :penalty_60min, :penalty_90min, :penalty_eod_unseen, :penalty_turbo, :md_hourly]

  (OPTIMIZER_FIELDS).each do |field|
    validates field, presence: true, numericality: { greater_than_or_equal_to: 0, less_than: 5000 }
  end

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
      md_hourly: Position.find_by(key: :md).hourly_rate,
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

  def analysis(zone = nil)
    @_analysis ||= {}
    @_analysis[zone] ||= begin
      lp = zone ? location_plans.for_zone(zone).includes(:chosen_grade) : location_plans.includes(:chosen_grade)
      grades = lp.map(&:chosen_grade)
      Analysis.new(grades)
    end
  end

  def any_updates?
    check_for_updates.values.include? true
  end

  def check_for_updates
    new_heatmaps, new_forecasts, new_locations = false, false, false

    forecasts = PatientVolumeForecast.where(start_date: ((starts_on-6)..ends_on) )
    forecasts_updates = forecasts.map(&:updated_at).max

    # FOOBAR
    # location_plans.each do |lp|
    #   new_locations = true if lp.updated_at < lp.location.updated_at
    #   new_heatmaps = true if lp.visit_projection.updated_at < Heatmap.find_by!(uid: lp.location.uid).updated_at
    #   new_forecasts = true if lp.visit_projection.updated_at < forecasts_updates
    # end

    {heatmaps: new_heatmaps, forecasts: new_forecasts, location: new_locations}
  end

  def locations
    location_plans.map(&:location).uniq
  end

  def zones
    locations.map(&:zone).uniq
  end

  def lps_complete?
    check_complete(location_plans)
  end

  def zone_complete?(zone)
    check_complete(location_plans.for_zone(zone))
  end

  private

    def check_complete(lps)
      !lps.empty? && !lps.map(&:complete?).include?(false)
    end

end
