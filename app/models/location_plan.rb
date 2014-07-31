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

  has_many :pushes, dependent: :destroy

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  LIFE_CYCLE = [  [0, 0],
                  [1, 94],                      # life cycle 1
                  [51, 143],                    # life cycle 2
                  [76, 188],                    # etc...
                  [101, 237],
                  [131, 282],
                  [166, 330],
                  [201, 376] ]                  # [min_daily_patients_in_life_cycle, max_weekly_physician_hours_for_life_cycle]

  enum approval_state: [:pending, :manager_approved, :gm_approved]

  delegate :name, to: :location

  validates :location, presence: true
  validates :schedule, presence: true

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }

  scope :for_user, -> (user) { where(location_id: user.relevant_locations.pluck(:id)) }

  scope :assigned, -> { where( location_id: Zone.assigned.map(&:location_ids) ) }

  scope :ordered, -> { joins(:location).order('locations.name ASC')}


  # For a given collection of location_plans, return their 'base' state
  # If any are pending, then the whole collective state is pending
  def self.collective_state(location_plans)
    int_states = location_plans.map{|lp| lp[:approval_state]}
    LocationPlan.approval_states.key(int_states.min || 0)
  end

  def life_cycle
    avg = visit_projection.daily_avg

    for i in (0...LIFE_CYCLE.size)
      lc = i if (avg > LIFE_CYCLE[i][0])
    end
    lc
  end

  def life_cycle_max_daily_hours
    LIFE_CYCLE[life_cycle][1] / 7.0
  end

  def life_cycle_max_total_hours
    life_cycle_max_daily_hours * visit_projection.total_days
  end

  def solution_set_options(day)
    set_solution_set_inputs(day)
    {open: open_times[day.wday()], close: close_times[day.wday()], max_mds: max_mds, min_openers: min_openers, min_closers: min_closers}
  end

  # Loads the set of possible shift coverages for a single day
  # given the stored LocationPlan location configuration
  def build_solution_set(day)
    set_solution_set_inputs(day)
    SolutionSetBuilder.new(self, day).build
  end

#TODO should these am_min method be called on visits rather than VisitProjection?
  def set_solution_set_inputs(day)
    max = self.visit_projection.day_max(day)
    self.max_mds = normal.length
    normal.each_with_index do |speed, i|
      if speed/2 > max
        self.max_mds= i + 1
        break
      end
    end
    am_min = self.visit_projection.am_min(day)
    self.min_openers= 1
    normal.each_with_index do |speed, i|
      if speed/2 > am_min && i > 0
        self.min_openers= i
        break
      end
    end
    pm_min = self.visit_projection.pm_min(day)
    self.min_closers= 1
    normal.each_with_index do |speed, i|
      if speed/2 > pm_min && i > 0
        self.min_closers= i
        break
      end
    end
    self.save!
  end


  def unoptimized_summed_points
    @_points ||= Grade.unoptimized_sum(chosen_grade)
  end

  # Copies the chosen grade to a new grade
  def copy_grade!(user)
    LocationPlan.transaction do
      g = self.grades.create!(chosen_grade.attributes.merge(id: nil, created_at: nil, source: 'manual', user: user))
      g.clone_shifts_from!(chosen_grade)
      self.update_attribute(:chosen_grade_id, g.id)

      g
    end
  end

# Arrays of decimals are stored as as strings in Postgres
  def normal
    read_attribute(:normal).map(&:to_f)
  end

  def max
    read_attribute(:max).map(&:to_f)
  end

end
