require 'spec_helper'

RSpec.describe ShiftCoverage, :type => :model do
  # Location plan must alwasy start at the same hour of the day because it determines our coverage array
  let (:location_plan) { create(:location_plan, open_times: [8,8,8,8,8,8,8], close_times: [21,21,21,21,21,21,21]) }
  let (:grade)         { location_plan.chosen_grade }

  # Starts at 10am
  let (:shift)         { create(:shift, grade: grade, starts_at: Time.zone.now.beginning_of_day + 10.hours) }

  describe "Converting Shifts to Coverage" do
    it "converts correctly" do
      sc = ShiftCoverage.new(location_plan, shift.starts_at.to_date)
      exp = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0]

      expect( sc.shifts_to_coverage([shift]) ).to eql(exp)
    end
  end

  describe "Converting Shifts to Coverage" do
    it "converts correctly" do
      coverage = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0]
      sc = ShiftCoverage.new(location_plan, Time.zone.now.to_date)
      shifts = sc.coverage_to_shifts(coverage)

      expect( shifts.length ).to eql(1)
      expect( shifts.first.starts_at.hour ).to eql(10)
      expect( shifts.first.ends_at.hour ).to eql(18)
    end
  end
end
