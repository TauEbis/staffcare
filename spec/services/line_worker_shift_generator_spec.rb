require 'spec_helper'

describe LineWorkerShiftGenerator, :type => :service do
  let(:location_plan) { create(:location_plan) }
  let(:shift1)        { create(:shift, grade: location_plan.chosen_grade) }
  let(:generator)     { LineWorkerShiftGenerator.new(location_plan) }
  let(:grade)         { location_plan.chosen_grade }

  before { FactoryGirl.create(:position, key: :ma) }

  describe "Creating shifts for different policies" do

    it "Limit 1 policy" do
      generator.stub(:policy_for_line).and_return(:limit_1)
      stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds

      expected_starts = []
      expected_ends = []
      location_plan.schedule.days.each do |day|
          expected_starts << day.in_time_zone(Shift::TZ).change(hour: location_plan.open_times[day.wday])
          expected_ends   << day.in_time_zone(Shift::TZ).change(hour: location_plan.close_times[day.wday])
      end

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

    it "Limit 1.5 policy" do
      generator.stub(:policy_for_line).and_return(:limit_1_5)
      stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds

      expected_starts = []
      expected_ends = []
      location_plan.schedule.days.each do |day|
          open = day.in_time_zone(Shift::TZ).change(hour: location_plan.open_times[day.wday])
          close = day.in_time_zone(Shift::TZ).change(hour: location_plan.close_times[day.wday])
          twenty_five_percent = (close - open) / 4

          expected_starts.push(open, open + twenty_five_percent)
          expected_ends.push(close - twenty_five_percent, close)
      end

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

    it "Limit 2 policy" do
      generator.stub(:policy_for_line).and_return(:limit_2)
      stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds

      expected_starts = []
      expected_ends = []
      location_plan.schedule.days.each do |day|
          2.times { expected_starts << day.in_time_zone(Shift::TZ).change(hour: location_plan.open_times[day.wday])
                    expected_ends   << day.in_time_zone(Shift::TZ).change(hour: location_plan.close_times[day.wday]) }
      end

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

    it "Ratio 1 policy" do
      generator.stub(:policy_for_line).and_return(:ratio_1)

      expected_starts = [ shift1.starts_at ]
      expected_ends = [ shift1.ends_at ]

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

    it "Ratio 1.5 policy" do
      generator.stub(:policy_for_line).and_return(:ratio_1_5)

      twenty_five_percent = (shift1.ends_at - shift1.starts_at) / 4
      expected_starts = [ shift1.starts_at, shift1.starts_at + twenty_five_percent ]
      expected_ends = [ shift1.ends_at - twenty_five_percent, shift1.ends_at ]

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

    it "Ratio 2 policy" do
      generator.stub(:policy_for_line).and_return(:ratio_2)
      expected_starts = [ shift1.starts_at ] * 2
      expected_ends = [ shift1.ends_at ] * 2

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

  end

  describe "Splitting long shifts" do

    let(:day)           {location_plan.schedule.days.first}
    let(:long_shift)   { create(:shift,  starts_at: day.in_time_zone(Shift::TZ).change(hour: 8),
                                          ends_at: day.in_time_zone(Shift::TZ).change(hour: 22),
                                          grade: location_plan.chosen_grade) }

    it "should split into two close to equal shifts" do
      generator.stub(:policy_for_line).and_return(:ratio_1)
      stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (10 * 60 * 60)) # 10 hours in seconds

      mid = (long_shift.ends_at - long_shift.starts_at) / 2

      expected_starts = [ long_shift.starts_at, long_shift.starts_at + mid ]
      expected_ends = [ long_shift.ends_at - mid, long_shift.ends_at ]

      generator.create!
      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end
  end
end