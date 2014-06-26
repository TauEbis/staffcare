# A generated and scored schedule
class Schedule < ActiveRecord::Base

  has_many :visit_projections, dependent: :destroy
  has_many :location_plans, dependent: :destroy

  enum state: [ :draft, :active, :published, :archived ]

  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
  scope :ordered, -> { order(starts_on: :desc, id: :desc) }

  default_scope -> { order(starts_on: :desc, id: :desc) }

  OPTIMIZER_FIELDS = [:penalty_30min, :penalty_60min, :penalty_90min, :penalty_eod_unseen, :penalty_slack, :md_rate, :oren_shift]

  OPTIMIZER_FIELDS.each do |field|
    validates field, presence: true
  end

  validates :starts_on, presence: true

  def self.default_attributes
    {
      penalty_30min: 1,
      penalty_60min: 4,
      penalty_90min: 16,
      penalty_eod_unseen: 2,
      penalty_slack: 2.5,
      md_rate: 4.25,
      oren_shift: true
    }
  end

  def ends_on
    @_ends_on ||= starts_on + 27
  end

  def custom_length(length) # Method for faster testing
    @_ends_on = starts_on + length
  end

  def days
    @_days ||= (starts_on..ends_on).to_a
  end

  def grader_weights
    @_grader_weights ||= self.attributes.slice(*OPTIMIZER_FIELDS.map(&:to_s)).symbolize_keys
  end

  def optimize!
    grader = CoverageGrader.new(grader_weights)
    picker = CoveragePicker.new(grader)
    loader = SpeedySolutionSetLoader.new

    location_plans.each do |location_plan|
      coverages = {}
      breakdowns = {}

      days.each do |day|
        day_visits = location_plan.visits[day.to_s]
        # Load the valid shift start/stop times for that site and day
        solution_set = loader.load(location_plan, day)

        best_coverage, best_breakdown = picker.pick_best(solution_set, day_visits)
        coverages[day.to_s] = best_coverage
        breakdowns[day.to_s] = best_breakdown
      end

      grade = location_plan.grades.new(source: 'optimizer', coverages: coverages, breakdowns: breakdowns)

      grade.save!
    end
  end
end
