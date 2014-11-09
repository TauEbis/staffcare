require 'spec_helper'

describe LineWorkerShiftGenerator, :type => :service do
  let(:grade)         { create(:grade) }
  let(:rule)          { FactoryGirl.create(:rule, position: create(:position, key: :ma), grade: grade) }
  let(:generator)     { LineWorkerShiftGenerator.new(grade) }

  let(:days)          { grade.location_plan.schedule.days }
  let(:open_times)    { grade.location_plan.open_times}
  let(:close_times)   { grade.location_plan.close_times}


  describe "Creating shifts for different policies" do
    let(:expected_starts) {[]}
    let(:expected_ends)   {[]}

    describe "Limit 1 policy" do

      before do
        rule.limit_1!
        stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds
        generator.create!
      end

      it 'should generate single coverage' do
        days.each do |day|
            expected_starts << day.in_time_zone(Shift::TZ).change(hour: open_times[day.wday])
            expected_ends   << day.in_time_zone(Shift::TZ).change(hour: close_times[day.wday])
        end

        expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
        expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
      end

    end

    describe "Limit 1.5 policy" do

      before do
        rule.limit_1_5!
        stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds
        generator.create!
      end

      it "should generate one and a half coverage" do
        days.each do |day|
            open = day.in_time_zone(Shift::TZ).change(hour: open_times[day.wday])
            close = day.in_time_zone(Shift::TZ).change(hour: close_times[day.wday])
            twenty_five_percent = (close - open) / 4

            expected_starts.push(open, open + twenty_five_percent)
            expected_ends.push(close - twenty_five_percent, close)
        end

        expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
        expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
      end

    end

    describe "Limit 2 policy" do

      before do
        rule.limit_2!
        stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (20 * 60 * 60)) # 20 hours in seconds
        generator.create!
      end

      it "should generate double coverage" do
        days.each do |day|
            2.times { expected_starts << day.in_time_zone(Shift::TZ).change(hour: open_times[day.wday])
                      expected_ends   << day.in_time_zone(Shift::TZ).change(hour: close_times[day.wday]) }
        end

        expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
        expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
      end

    end

    describe "Ratio policies: " do
      let!(:shift1)        { create(:shift, grade: grade) }

      describe "Ratio 1 policy" do

        before do
          rule.ratio_1!
          generator.create!
        end

        it "should generate a shift for every physician shift" do
          expected_starts = [ shift1.starts_at ]
          expected_ends = [ shift1.ends_at ]

          expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
          expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
        end

      end

      describe "Ratio 1.5 policy" do

        before do
          rule.ratio_1_5!
          generator.create!
        end

        it "should generate one and half shifts for each physician shift" do
          twenty_five_percent = (shift1.ends_at - shift1.starts_at) / 4
          expected_starts = [ shift1.starts_at, shift1.starts_at + twenty_five_percent ]
          expected_ends = [ shift1.ends_at - twenty_five_percent, shift1.ends_at ]

          expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
          expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
        end

      end

      describe "Ratio 2 policy" do

        before do
          rule.ratio_2!
          generator.create!
        end

        it "should generate 2 shifts for each physician shift" do
          expected_starts = [ shift1.starts_at ] * 2
          expected_ends = [ shift1.ends_at ] * 2

          expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
          expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
        end

      end
    end
  end

  describe "Splitting long shifts" do

    let!(:long_shift)   { create(:shift,  starts_at: days.first.in_time_zone(Shift::TZ).change(hour: 8),
                                          ends_at: days.first.in_time_zone(Shift::TZ).change(hour: 22),
                                          grade: grade) }

    before do
      rule.ratio_1!
      stub_const('LineWorkerShiftGenerator::MAX_LENGTH', (10 * 60 * 60)) # 10 hours in seconds
      generator.create!
    end

    it "should split into two close to equal shifts" do
      mid = (long_shift.ends_at - long_shift.starts_at) / 2
      expected_starts = [ long_shift.starts_at, long_shift.starts_at + mid ]
      expected_ends = [ long_shift.ends_at - mid, long_shift.ends_at ]

      expect(grade.shifts.ma.map(&:starts_at)).to eql(expected_starts)
      expect(grade.shifts.ma.map(&:ends_at)).to eql(expected_ends)
    end

  end
end