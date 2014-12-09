# Represents a score for a particular optimization for a stored
# location configuration. The manual and last_month source are preserved/cached,
# the optimizer grade is always from the schedule generation that created the location_plan
# that the grade belongs to.
class Grade < ActiveRecord::Base
  belongs_to :location_plan
  belongs_to :location
  belongs_to :schedule
  belongs_to :visit_projection
  belongs_to :user
  has_many :shifts, dependent: :destroy
  has_many :rules
  #belongs_to :ma_rule, class_name: 'Rule' # Do we require this functionality or is grade.rules.ma.first OK?

  attr_reader :source_grade_id

  OPTIMIZER_FIELDS = [:max_mds, :rooms, :min_openers, :min_closers, :open_times, :close_times]

  delegate :name, :ftes, to: :location
  delegate :days, to: :schedule

  enum source: [:optimizer, :last_month, :manual]
  enum optimizer_state: [ :not_run, :running, :complete, :error ]

  before_destroy :reset_chosen_grade

  accepts_nested_attributes_for :shifts

  scope :for_zone, -> (zone) { where(location_id: zone.location_ids) }
  scope :for_user, -> (user) { where(location_id: user.relevant_locations.pluck(:id)) }
  scope :assigned, -> { where(location_id: Location.assigned.pluck(:id)) }
  #scope :ordered, -> { joins(:location).order('locations.name ASC')}
  scope :ordered, -> { order(source: :asc, created_at: :desc) }

  validates :schedule, presence: true
  validates :visit_projection, presence: true
  validates :visits, presence: true
  validates :location, presence: true
  validates :rooms, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :max_mds, presence: true, numericality: { greater_than: 0, less_than: 100 }
  validates :open_times, presence: true
  validates :close_times, presence: true
  # validates :normal, presence: true
  # validates :max, presence: true

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

  def label
    case source
      when 'optimizer'
        "Optimized Coverage"
      when 'manual'
        "Manual Coverage by #{user.try(:label)} [ #{I18n.localize created_at} ]"
      when 'last_month'
        'Coverage from previous month'
      else
        'Unknown'
    end
  end


  # shifts comes in as [{"id"=>612, "starts"=>8, "ends"=>12, "hours"=>4, "position_key"=>"md"}, {"id"=>613, "starts"=>12, "ends"=>20, "hours"=>8, "position_key"=>"md"}]
  def update_shift!(date, raw_shifts)
    date_s = date.to_s

    old_shifts = self.shifts.for_day(date).index_by(&:id)
    old_ids    = old_shifts.keys

    new_ids    = raw_shifts.map{|s| s['id']}
    shifts = []

    raw_shifts.each do |raw_shift|
      shift = old_shifts[raw_shift['id']] || self.shifts.build
      shift = shift.from_knockout(date, raw_shift)
      shift.save!
      shifts << shift
    end

    # Deletes
    (old_ids - new_ids).each do |id|
      old_shifts[id].destroy
    end

    coverages_will_change!
    self.coverages[date_s] = ShiftCoverage.new().shifts_to_coverage(self.shifts.md.for_day(date))

    calculate_grade!(date_s)
    # TODO: unoptimized_sum is already recalculating, but if that is cached we'll need to recalc here

    self.save!
  end

  def calculate_grade!(date_s, grader = nil)
    breakdowns_will_change!
    points_will_change!

    grader ||= CoverageGrader.new(grader_opts)
    self.breakdowns[date_s], self.points[date_s] = grader.full_grade(coverages[date_s], visits[date_s])
  end

  def reset_chosen_grade
    if location_plan.chosen_grade == self
      new_grade_id = location_plan.grades.where('id <> ?', id).order(id: :asc).first.try(:id)
      location_plan.update_attribute(:chosen_grade_id, new_grade_id) if new_grade_id
    end
  end

  def clone_shifts_from!(other_grade)
    other_grade.shifts.each do |other_shift|
      self.shifts.build(other_shift.attributes.except('id', 'grade_id'))
    end

    self.save!
  end

  def for_highcharts(date)
    date_s = date.to_s
    b = breakdowns[date_s]
    size = visits[date_s].size
    range = (0...size)
=begin
    normal_data = range.map do |i|
      num_mds = coverages[date_s][i]
      (normal[num_mds] / 2.0).round(2).to_f  # Div 2.0 for half hours instad of hours
    end
=end
    max_data = range.map do |i|
      num_mds = coverages[date_s][i]
      (max[num_mds] / 2.0).round(2).to_f  # Div 2.0 for half hours instad of hours
    end

    seen_normal_data = range.map do |i|
      (b['seen'][i] - b['turbo'][i]).round(2)
    end

    waiting_data = range.map do |i|
      visits[date_s][i].round(2) + b['queue'][i].round(2)
    end

    start = open_times[date.wday]
    x_axis = (0..size).map {|i| (start + (i / 2.0)).to_time_of_day }

    {
      visits_data: visits[date_s].map{|i| i.round(2)},
      seen_normal_data: seen_normal_data,
      queue_data: b['queue'].map{|i| i.round(2)},
      turbo_data: b['turbo'].map{|i| i.round(2)},
      slack_data: b['slack'].map{|i| i.round(2)},
      waiting_data: waiting_data,
      # penalty_data: b['penalties'].map{|i| i.round(2)},
      # normal_data: normal_data,
      max_data: max_data,
      x_axis: x_axis
    }
  end


###### Methods for supporting the Analysis introspection

  def plans_optimized_grade
    @_plans_optimized_grade ||= location_plan.grades.optimizer.last
  end

  def analysis(date = nil)
    @_analysis ||= Analysis.new(self, date)
  end

  def over_staffed?(date_s)
    @_over_staffed ||= {}
    @_over_staffed[date_s] ||= ( coverages[date_s].index { |x| x > (normal.length - 1) } != nil )
  end

  def over_staffing_wasted_mins(date_s)
    @_over_staffed_wasted_mins ||= {}
    @_over_staffed_wasted_mins[date_s] ||= begin
      coverage = coverages[date_s]
      limit = normal.length - 1                         # Subtract 1 since normal[1] is first speed
      sheared_coverage = coverage.map { |n| [n,limit].min }           # Assumption is that above the limit adding mds does not increase capacity
      coverage.zip(sheared_coverage).map{ |x, y| x - y  }.sum * 30    # 30 minute blocks
    end
    @_over_staffed_wasted_mins[date_s]
  end

  # This is the one function that is not abstracted by Analysis
  # Because we need it for every single day to draw the calendar
  def pen_per_pat(date_s)
    points[date_s]['total'] / visits[date_s].sum # would totals(date)[:penalty]/totals(date)[:visits] be clearer?
  end

  def grader_opts
    schedule.grader_weights.merge({normal: normal, max: max})
  end

  def solution_set_options(day)
    @_ss_options ||= {}
    @_ss_options[day.to_s] ||= recalculate_solution_set_options(day)
  end

  # Loads the set of possible shift coverages for a single day
  # given the stored LocationPlan location configuration
  def build_solution_set(day)
    @_builder ||= SolutionSetBuilder.new
    @_builder.setup(solution_set_options(day))
    @_builder.build
  end

  private

  def recalculate_solution_set_options(day)

    top = [max_mds, normal.length-1].min

    # Find ceilng for max mds using visits and speeds
    max_hourly_visitors = 2 * day_max(day)
    day_max_mds = top # No point sending grader coverage it doesn't have speeds for
    top.downto(1).each do |x|
      normal[x] > max_hourly_visitors ? day_max_mds = x : break
    end

    # Find floor for min_openers using visits and speeds
    am_min_hourly_visitors = 2 * am_min(day)
    day_min_openers = min_openers
    (min_openers..top).each do |x|
      normal[x] < am_min_hourly_visitors ? day_min_openers = x : break
    end

    # Find floor for max_closers using visits and speeds
    pm_min_hourly_visitors = 2 * pm_min(day)
    day_min_closers = min_closers
    (min_closers..top).each do |x|
      normal[x] < pm_min_hourly_visitors ? day_min_closers = x : break
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

  def monthly_visits
    @_monthly_visits ||= visits.each_value.inject(0) { | total, v | total + v.sum }
  end

  def daily_avg
    @_daily_avg ||= monthly_visits / days.size
  end

  def weekly_avg
    @_weekly_avg ||= daily_avg * 7
  end

end
