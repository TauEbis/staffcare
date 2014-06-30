# Represents a score for a particular optimization for a stored
# location configuration. The manual and last_month source are preserved/cached,
# the optimizer grade is always from the schedule generation that created the location_plan
# that the grade belongs to.
class Grade < ActiveRecord::Base
  belongs_to :location_plan

  enum source: [:optimizer, :last_month, :manual]

  scope :ordered, -> { order(source: :asc, created_at: :desc) }

  def label
    case source
      when 'optimizer'
        "Optimized Coverage"
      when 'manual'
        "Manual Coverage #{created_at}"
      when 'last_month'
        'Coverage from previous month'
      else
        'Unknown'
    end
  end

  def update_shift!(date_s, dow, shifts)
    coverages_will_change!
    start_time = location_plan.open_times[dow]
    end_time   = location_plan.close_times[dow]

    self.coverages[date_s] = Grade.shifts_to_coverage(start_time,end_time,shifts)

    calculate_grade!(date_s)
    # TODO: unoptimized_sum is already recalculating, but if that is cached we'll need to recalc here

    self.save!
  end

  # shifts comes in as [{"starts"=>8, "ends"=>12, "hours"=>4}, {"starts"=>12, "ends"=>20, "hours"=>8}]
  # TODO This needs some testing!
  def self.shifts_to_coverage(start_time, end_time, shifts)
    starts = shifts.map{|s| s['starts']}.sort.reverse
    ends   = shifts.map{|s| s['ends']}.sort.reverse

    cnt = 0
    cvg = []

    (start_time...end_time).step(0.5) do |hour|
      puts hour
      while starts[-1] == hour
        starts.pop
        cnt +=1
      end

      while ends[-1] == hour
        ends.pop
        cnt -=1
      end

      cvg << cnt
    end

    cvg
  end

  def calculate_grade!(date_s, grader = nil)
    breakdowns_will_change!
    points_will_change!

    grader ||= CoverageGrader.new(self.location_plan.schedule.grader_weights)
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

end
