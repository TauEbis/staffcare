# Records location configuration at time a schedule is generated
# Corresponds to a per-location schedule in the UI
class LocationPlan < ActiveRecord::Base
  belongs_to :location
  belongs_to :schedule
  belongs_to :visit_projection

  # grades records the grading/score for the schedule for the given scheduling options-
  # e.g., use last months schedule, use manual coverage, etc.
  has_many :grades, dependent: :destroy
  belongs_to :chosen_grade, class_name: 'Grade'

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  enum approval_state: [:pending, :manager_approved, :gm_approved]

  delegate :name, to: :location

  validates :location, presence: true
  validates :schedule, presence: true

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }

  scope :ordered, -> { joins(:location).order('locations.name ASC')}

  # For a given collection of location_plans, return their 'base' state
  # If any are pending, then the whole collective state is pending
  def self.collective_state(location_plans)
    int_states = location_plans.map{|lp| lp[:approval_state]}
    LocationPlan.approval_states.key(int_states.min || 0)
  end

  def solution_set_options(day)
    {open: open_times[day.wday()], close: close_times[day.wday()], max_mds: max_mds, min_openers: min_openers, min_closers: min_closers}
  end

  # Loads the set of possible shift coverages for a single day
  # given the stored LocationPlan location configuration
  def build_solution_set(day)
    SolutionSetBuilder.new(self, day).build
  end

  def unoptimized_summed_points
    @_points ||= Grade.unoptimized_sum(chosen_grade)
  end

  # Copies the chosen grade to a new grade
  def copy_grade!(user)
    LocationPlan.transaction do
      g = self.grades.create!(chosen_grade.attributes.merge(id: nil, created_at: nil, source: 'manual', user: user))
      self.update_attribute(:chosen_grade_id, g.id)

      g
    end
  end
end
