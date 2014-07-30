# A generated and scored schedule
class Schedule < ActiveRecord::Base

  has_many :visit_projections, dependent: :destroy
  has_many :location_plans, dependent: :destroy

  enum state: [ :draft, :active, :published, :archived ]

  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  scope :not_draft, -> { where("state <> ?", Schedule.states[:draft]) }
  scope :ordered, -> { order(starts_on: :desc, id: :desc) }

  default_scope -> { order(starts_on: :desc, id: :desc) }

  OPTIMIZER_FIELDS = [:penalty_30min, :penalty_60min, :penalty_90min, :penalty_eod_unseen, :penalty_turbo, :penalty_slack, :oren_shift]

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
      penalty_turbo: 3,
      penalty_slack: 2,
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

  def optimize!
    grader = CoverageGrader.new(grader_weights)
    picker = CoveragePicker.new(grader)
    loader = SpeedySolutionSetLoader.new

    location_plans.each do |location_plan|
      coverages = {}
      breakdowns = {}
      points = {}
      shifts = []
      grader.set_speeds location_plan.normal, location_plan.max

      days.each do |day|
        day_visits = location_plan.visits[day.to_s]
        # Load the valid shift start/stop times for that site and day
        solution_set = loader.load(location_plan, day)

        best_coverage, best_breakdown, best_points = picker.pick_best(solution_set, day_visits)
        coverages[day.to_s] = best_coverage
        breakdowns[day.to_s] = best_breakdown
        points[day.to_s] = best_points
        shifts += ShiftCoverage.new(location_plan, day).coverage_to_shifts(best_coverage)
      end

      grade = location_plan.grades.new(source: 'optimizer', coverages: coverages, breakdowns: breakdowns, points: points, shifts: shifts)

      grade.save!
      location_plan.update_attribute(:chosen_grade_id, grade.id)
    end
  end

  def unoptimized_summed_points(zone = nil)
    @_points ||= {}
    @_points[zone] ||= begin
      lp = zone ? location_plans.for_zone(zone) : location_plans
      # TODO lp = lp.includes(:chosen_grade)
      Grade.unoptimized_sum(lp.map(&:chosen_grade))
    end
  end
end
