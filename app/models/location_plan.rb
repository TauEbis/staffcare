# Records location configuration at time a schedule is generated
# Corresponds to a per-location schedule in the UI
class LocationPlan < ActiveRecord::Base
  belongs_to :location
  belongs_to :schedule
  belongs_to :visit_projection

  # grades records the grading/score for the schedule for the given scheduling options-
  # e.g., use last months schedule, use manual coverage, etc.
  has_many :grades, dependent: :destroy
  belongs_to :chosen_grade

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  enum approval_state: [:pending, :approved]

  delegate :name, to: :location

  validates :location, presence: true
  validates :schedule, presence: true

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }

  scope :ordered, -> { joins(:location).order('location_plans.approval_state ASC, locations.name ASC')}

  # For a give collection of location_plans, return their 'base' state
  # If any are pending, then the whole collective state is pending
  def self.collective_state(location_plans)
    location_plans.map(&:approval_state).any?{|s| s == 'pending'} ? 'pending' : 'approved'
  end

  def solution_set_options(day)
    {open: open_times[day.wday()], close: close_times[day.wday()], max_mds: max_mds, min_openers: min_openers, min_closers: min_closers}
  end

  # Loads the set of possible shift coverages for a single day
  # given the stored LocationPlan location configuration
  def build_solution_set(day)
    SolutionSetBuilder.new(self, day).build
  end

  def shifts(grade, day)
    open_set = shift_opens(grade, day)
    close_set = shift_closes(grade, day)

    size_diff = open_set.size - close_set.size
    if size_diff != 0
      open_set, close_set = normalize(open_set, close_set, size_diff)
    end

    open_set.zip(close_set)
  end

  def shift_opens(grade, day)

    coverage = grade.coverages[day.to_s]
    morning = coverage[0..(coverage.size/2)]
    opens_at = open_times[day.wday]

    open_set=Array.new(morning[0], opens_at)

    (1..(morning.size-1)).each do |index|
      md_change = (morning[index] - morning[index-1])
      md_change.times do |y|
        hour = index/2 + opens_at
        open_set << hour
      end
    end

    open_set
  end

  def shift_closes(grade, day)

    coverage = grade.coverages[day.to_s]
    evening = coverage[(coverage.size/2 -1)..-1]
    closes_at = close_times[day.wday()]
    opens_at = open_times[day.wday]
    midday = opens_at + (closes_at - opens_at)/2

    close_set = []

    (1..(evening.size-1)).each do |index|
      md_change = (evening[index-1] - evening[index])
      md_change.times do |y|
        hour =  midday + (index-1)/2
        close_set << hour
      end
    end

    evening[-1].times { |i| close_set << closes_at}

    close_set
  end

# TODO: determine if this case occurs and test it
   def normalize(open_set, close_set, size_diff)
    closes_at = close_times[day.wday()]
    opens_at = open_times[day.wday]
    midday = opens_at + (closes_at - opens_at)/2

    if size_diff < 0
      size_diff.times { |i| open_set << midday }
    elsif size_diff > 0
      size_diff.times { |i| close_set.unshift(midday) }
    end

    return open_set, close_set

  end

  def crazy_grade
    chosen_grade || grades.first
  end

  def unoptimized_summed_points
    @_points ||= Grade.unoptimized_sum(crazy_grade)
  end
end
