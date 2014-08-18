# Represents a score for a particular optimization for a stored
# location configuration. The manual and last_month source are preserved/cached,
# the optimizer grade is always from the schedule generation that created the location_plan
# that the grade belongs to.
class Grade < ActiveRecord::Base
  belongs_to :location_plan
  belongs_to :user
  has_many :shifts, dependent: :destroy

  enum source: [:optimizer, :last_month, :manual]

  scope :ordered, -> { order(source: :asc, created_at: :desc) }

  before_destroy :reset_chosen_grade

  accepts_nested_attributes_for :shifts

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


  def for_highcharts(date)
    date_s = date.to_s
    b = breakdowns[date_s]
    size = location_plan.visits[date_s].size
    range = (0...size)

    normal_data = range.map do |i|
      num_mds = coverages[date_s][i]
      (location_plan.normal[num_mds - 1] / 2.0).round(2)  # Div 2.0 for half hours instad of hours
    end

    max_data = range.map do |i|
      num_mds = coverages[date_s][i]
      (location_plan.max[num_mds - 1] / 2.0).round(2)  # Div 2.0 for half hours instad of hours
    end

    seen_normal_data = range.map do |i|
      (b['seen'][i] - b['turbo'][i]).round(2)
    end

    waiting_data = range.map do |i|
      location_plan.visits[date_s][i].round(2) + b['queue'][i].round(2)
    end

    start = location_plan.location.open_times[date.wday]
    x_axis = (0..size).map {|i| (start + (i / 2.0)).to_time_of_day }

    {
      visits_data: location_plan.visits[date_s].map{|i| i.round(2)},
      seen_normal_data: seen_normal_data,
      queue_data: b['queue'].map{|i| i.round(2)},
      turbo_data: b['turbo'].map{|i| i.round(2)},
      slack_data: b['slack'].map{|i| i.round(2)},
      waiting_data: waiting_data,
      # penalty_data: b['penalties'].map{|i| i.round(2)},
      normal_data: normal_data,
      max_data: max_data,
      x_axis: x_axis
    }
  end

  # shifts comes in as [{"id"=>612, "starts"=>8, "ends"=>12, "hours"=>4}, {"id"=>613, "starts"=>12, "ends"=>20, "hours"=>8}]
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
    self.coverages[date_s] = ShiftCoverage.new(location_plan, date).shifts_to_coverage(shifts)

    calculate_grade!(date_s)
    # TODO: unoptimized_sum is already recalculating, but if that is cached we'll need to recalc here

    self.save!
  end

  def calculate_grade!(date_s, grader = nil)
    breakdowns_will_change!
    points_will_change!

    grader ||= CoverageGrader.new(self.location_plan.schedule.grader_weights)
    grader.set_speeds self.location_plan.normal, self.location_plan.max
    day_visits = location_plan.visits[date_s]

    grader.penalty(self.coverages[date_s], day_visits)

    self.breakdowns[date_s] = grader.breakdown
    self.points[date_s] = grader.points
  end

  def self.unoptimized_sum(grades)
    grades = Array(grades)
    p = {}

    grades.each do |g|
      ['total', 'md_sat', 'patient_sat', 'cost', 'hours'].each do |field|
        p[field] ||= 0
        p[field] += g.points.sum {|k,v| v[field] } / grades.size
      end
    end

    p
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

  def totals(date)
    date_s = date.to_s
    b = breakdowns[date_s]
    {
      coverage: coverages[date_s].sum,
      visits: location_plan.visits[date_s].sum,
      work_rate: location_plan.visits[date_s].sum/coverages[date_s].sum,
      seen: b['seen'].sum,
      queue: b['queue'].sum,
      turbo: b['turbo'].sum,
      slack: b['slack'].sum,
      penalty: b['penalties'].sum,
    }
  end

end
