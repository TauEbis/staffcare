# Records location configuration at time a schedule is generated
# Corresponds to a per-location schedule in the UI
class LocationPlan < ActiveRecord::Base

  has_many :pushes, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :grades, dependent: :destroy
  # grades records the grading/score for the schedule for the given scheduling options-

  belongs_to :chosen_grade, class_name: 'Grade'
  belongs_to :location
  belongs_to :schedule
  belongs_to :visit_projection

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  enum approval_state: [:pending, :manager_approved, :rm_approved]
  enum wiw_sync: [:unsynced, :dirty, :synced]
  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  delegate :name, :ftes, to: :location
  delegate :days, to: :schedule

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }
  scope :for_user, -> (user) { where(location_id: user.relevant_locations.pluck(:id)) }
  scope :assigned, -> { where(location_id: Location.assigned.pluck(:id)) }
  scope :ordered, -> { joins(:location).order('locations.name ASC')}

  validates :schedule, presence: true
  validates :visit_projection, presence: true
  validates :visits, presence: true
  validates :location, presence: true
  validates :rooms, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :open_times, presence: true
  validates :close_times, presence: true
  validates :normal, presence: true
  validates :max, presence: true

  validate :valid_opens
  validate :valid_closes
  validate :valid_visits

# Custom Validations

  def valid_opens
    open_times.each do |t|
      unless 8 <=t && t <= 22
        errors.add(:base, "Site must open after 8AM and before 10PM")
        return
      end
    end
  end

  def valid_closes
    close_times.each do |t|
      unless 8 <=t && t <= 22
        errors.add(:base, "Site must close after 8AM and before 10PM")
        return
      end
    end
  end

  def valid_visits
    visits.each do |day, day_visits|
      dow = Date.parse(day).wday
      unless day_visits.size == 2 * (close_times[dow] - open_times[dow])
        errors.add(:base, "The visit projection must match the opening hours")
        return
      end
    end
  end

  # For a given collection of location_plans, return their 'base' state
  # If any are pending, then the whole collective state is pending
  def self.collective_state(location_plans)
    int_states = location_plans.map{|lp| lp[:approval_state]}
    LocationPlan.approval_states.key(int_states.min || 0)
  end

  def dirty!
    update_attribute(:wiw_sync, :dirty) if synced?
  end

  # Copies the chosen grade to a new grade
  def copy_grade!(grade, user)
    LocationPlan.transaction do
      g = self.grades.create!(grade.attributes.merge(id: nil, created_at: nil, source: 'manual', user: user))
      g.clone_shifts_from!(grade)
      self.update_attribute(:chosen_grade_id, g.id)
      dirty!

      g
    end
  end

  def solution_set_options(day)
    @_ss_options ||= {}
    @_ss_options[day.to_s] ||= recalculate_solution_set_options(day)
  end

  # Loads the set of possible shift coverages for a single day
  # given the stored LocationPlan location configuration
  def build_solution_set(day)
    @_builder ||= SolutionSetBuilder.new
    @_builder.set_up(solution_set_options(day))
    @_builder.build
  end

  private

    #TODO should the am_min method be called on visits rather than VisitProjection?
    def recalculate_solution_set_options(day)
      # Find ceilng for max mds using visits and speeds
      max_half_hourly_visitors = day_max(day)
      day_max_mds = normal.length - 1
      normal.each_with_index do |speed, i|
        if speed/2 > max_half_hourly_visitors
          day_max_mds = i
          break
        end
      end

      # Find floor for min_openers using visits and speeds
      am_min = am_min(day)
      day_min_openers = self.min_openers
      normal.each_with_index do |speed, i|
        if speed/2 > am_min && i > 1
          day_min_openers= [i - 1, 1].max
          break
        end
      end

      # Find floor for min_closers using visits and speeds
      pm_min = pm_min(day)
      day_min_closers = 1
      normal.each_with_index do |speed, i|
        if speed/2 > pm_min && i > 1
          day_min_closers= [i - 1, 1].max
          break
        end
      end

      {open: open_times[day.wday()], close: close_times[day.wday()], max_mds: day_max_mds, min_openers: day_min_openers, min_closers: day_min_closers}
    end

    # Visits level logic -- extraction candidate
    def day_max(day)
      visits[day.to_s].max
    end

    def am_min(day)
      length = visits[day.to_s].length
      visits[day.to_s][0..(length/2 -1)].min
    end

    def pm_min(day)
      length = visits[day.to_s].length
      visits[day.to_s][(length/2)..-1].min
    end

    def sum
      visits.each_value.inject(0) { | total, v | total + v.sum }
    end

    def daily_avg
      sum / days.size
    end

    def week_avg
      daily_avg * 7
    end

end
