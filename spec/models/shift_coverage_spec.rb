require 'spec_helper'

RSpec.describe ShiftCoverage, :type => :model do
  # Location plan must alwasy start at the same hour of the day because it determines our coverage array
  let (:location_plan) { create(:location_plan, open_times: [8,8,8,8,8,8,8], close_times: [22,22,22,22,22,22,22]) }

  # Starts at 10am
  let (:shift)         { create(:shift, grade: location_plan.chosen_grade, starts_at: Time.zone.now.beginning_of_day + 10.hours) }
  let (:sc)            { ShiftCoverage.new }

  describe "Converting Shifts to Coverage" do
    it "converts correctly" do
      shifts = [shift]
      coverage = sc.shifts_to_coverage(shifts)
      exp_coverage = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]

      expect( coverage ).to eql(exp_coverage)
    end
  end

  describe "Converting Coverage to Shifts" do
    it "converts correctly" do
      coverage = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]
      shifts = sc.coverage_to_shifts(coverage, location_plan, Time.zone.now.to_date)

      expect( shifts.length ).to eql(1)
      expect( shifts.first.starts_at.hour ).to eql(10)
      expect( shifts.first.ends_at.hour ).to eql(18)
    end
  end

  describe "sanity test private methods" do
    it "scores correctly" do
      set = [ [10, 18], [13, 22] ]
      expect(sc.send(:score, set)). to eq(35/2.0 )
    end
  end
end
