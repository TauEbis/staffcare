require 'spec_helper'

RSpec.describe ShiftCoverage, :type => :model do
  # Location plan must always start at the same hour of the day because it determines our coverage array
  let (:location_plan) { create(:location_plan, open_times: [8,8,8,8,8,8,8], close_times: [22,22,22,22,22,22,22]) }
  let (:sc)            { ShiftCoverage.new }

  describe "Converting Shifts to Coverage" do
    let (:shift)       { create(:shift, grade: location_plan.chosen_grade, starts_at: Time.zone.now.beginning_of_day + 10.hours) }
    let (:shift_2)     { create(:shift, grade: location_plan.chosen_grade, starts_at: Time.zone.now.beginning_of_day + 8.hours) }
    let (:shift_3)     { create(:shift, grade: location_plan.chosen_grade, starts_at: Time.zone.now.beginning_of_day + 14.hours) }

    it "converts correctly" do
      shifts = [shift]
      coverage = sc.shifts_to_coverage(shifts)
      exp_coverage = [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]

      expect( coverage ).to eql(exp_coverage)
    end

    it "converts 3 shifts correctly" do
      shifts = [shift, shift_2, shift_3]
      coverage = sc.shifts_to_coverage(shifts)
      exp_coverage = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1]

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

    it "converts overlapping coverage correctly" do
      coverage = [1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1]
      shifts = sc.coverage_to_shifts(coverage, location_plan, Time.zone.now.to_date)

      expect( shifts.length ).to eql(3)
      expect( shifts.map(&:starts_at).map(&:hour) ).to eql([8, 10, 14])
      expect( shifts.map(&:ends_at).map(&:hour) ).to eql([16, 18, 22])
    end

    it "picks best" do
      coverage = Array.new(28, 1)
      shifts = sc.coverage_to_shifts(coverage, location_plan, Time.zone.now.to_date)
      # It doesn't pick to split the shift because the average score is lower
      expect( shifts.length ).to eql(1)
      expect( shifts.first.starts_at.hour ).to eql(8)
      expect( shifts.first.ends_at.hour ).to eql(22)
    end
  end

  describe "#equiv_shifts_for" do
    it "respects the min_shift" do
      coverage = Array.new(16,1)
      sc.instance_variable_set(:@opens_at, 10)
      sc.instance_variable_set(:@min_shift, 6)
      expect(sc.equiv_shifts_for(coverage)).to eq [[[10,18]]]
    end
    it "splits long shifts" do
      coverage = Array.new(28,1)
      sc.instance_variable_set(:@opens_at, 8)
      sc.instance_variable_set(:@min_shift, 7)
      expect(sc.equiv_shifts_for(coverage)).to eq [ [[8,22]], [[8,15], [15,22]] ]
    end
  end

  describe "sanity test private methods" do
    it "#pick best: picks correctly" do
      set = [ [[8, 22]], [[8,15], [15,22]] ]
      expect(sc.send(:pick_best, set)). to eq([[8, 22]])
    end

    it "#score: scores correctly" do
      set = [ [10, 18], [13, 22] ]
      expect(sc.send(:score, set)). to eq(35/2.0 )
    end

    it "#opens_closes: provides the correct times" do
      sc.instance_variable_set(:@opens_at, 8)
      coverage = [1,1] + Array.new(20, 2) + Array.new(6, 1)
      opens = [8,9]
      closes = [19, 22]
      expect(sc.send(:opens_closes, coverage)). to eq([opens, closes] )
    end

    it "#opens_closes: provides the correct times" do
      sc.instance_variable_set(:@opens_at, 8)
      coverage = [] + Array.new(22, 2) + Array.new(6, 1)
      opens = [8,8]
      closes = [19, 22]
      expect(sc.send(:opens_closes, coverage)). to eq([opens, closes] )
    end

    it "#build_valid: knows how to recursively split shifts" do
      sc.instance_variable_set(:@opens_at, 8)
      sc.instance_variable_set(:@min_shift, 7)
      opens = [8, 8]
      closes = [22, 22]
      list = [ [ [8, 22], [8,22] ],
             [ [8,15], [8, 22], [15,22] ],
             [ [8,15], [8, 15], [15,22], [15,22] ] ]
      expect(sc.send(:build_valid, opens, closes )). to eq(list)
    end
  end
end
