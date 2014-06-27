# Represents a score for a particular optimization for a stored
# location configuration. The manual and last_month source are preserved/cached,
# the optimizer grade is always from the schedule generation that created the location_plan
# that the grade belongs to.
class Grade < ActiveRecord::Base
  belongs_to :location_plan

  enum source: [:optimizer, :last_month, :manual]

  def calculate_grade!(days, grader)
    days.each do |day|
      day_visits = location_plan.visits[day.to_s]

      grader.penalty(self.coverages, day_visits)

      self.breakdown = grader.breakdown
      self.points = grader.points
    end
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
