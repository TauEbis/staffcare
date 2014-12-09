require 'spec_helper'

describe Grade, :type => :model do
	let (:grade)         { location_plan.chosen_grade }
  let (:location_plan) { create :location_plan }
  subject { grade }

# Attributes
  it { should respond_to(:visits) }
  it { should respond_to(:max_mds) }
  it { should respond_to(:rooms) }
  it { should respond_to(:min_openers) }
  it { should respond_to(:min_closers) }
  it { should respond_to(:open_times) }
  it { should respond_to(:close_times) }
  it { should respond_to(:normal) }
  it { should respond_to(:max) }
  it { should respond_to(:optimizer_state) }
  it { should respond_to(:optimizer_job_id) }
  it { should respond_to(:open_times) }

  it { should be_valid }
  
  describe "normal attribute" do
    it "should save a array with a float" do
      grade.normal = [0.0, 5.5, 3.2, 1.1, 7.9, 2494.2933]
      expect(grade.save).to eq(true)

      expect(grade.reload.normal).to eql([0.0, 5.5, 3.2, 1.1, 7.9, 2494.2933])
    end
  end

  context "when an open_time is too early" do
    before { grade.open_times[0] = 7 }
    it {should_not be_valid}
  end

  context "when an open_time is too late" do
    before { grade.open_times[0] = 23 }
    it {should_not be_valid}
  end

  context "when an open_time is too early" do
    before { grade.close_times[0] = 7 }
    it {should_not be_valid}
  end

  context "when an open_time is too late" do
    before { grade.close_times[0] = 23 }
    it {should_not be_valid}
  end

  context "when visits open/close times don't match open/close times" do
    before { grade.visits.first[1] << [4] }
    it {should_not be_valid}
  end

  context "when open/close times don't match visits open/close times" do
    before { grade.open_times[1] = 10 }
    it {should_not be_valid}
  end

# Delegated Methods
  describe "delegated methods" do
    describe "#days" do
      it "should equal schedule's days" do
        expect(grade.days).to eq (grade.schedule.days)
      end
    end

    describe "#ftes" do
      it "should equal location's ftes" do
        expect(grade.ftes).to eq (grade.location.ftes)
      end
    end
  end

  describe "#grader_opts" do
    it "returns the speeds plus the schedule weights" do
      grade.schedule.update_attributes(md_hourly: 120,  penalty_turbo: 5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4)
      grade.normal = [0, 5, 6, 7, 8, 9]
      grade.max =    [0, 10, 12, 14, 16, 18]
      expected = { penalty_30min: 1.to_d, penalty_60min: 4.to_d, penalty_90min: 16.to_d, penalty_eod_unseen: 4.to_d, md_hourly: 120.to_d, penalty_turbo: 5.to_d,
                  normal: [0, 5, 6, 7, 8, 9], max: [0, 10, 12, 14, 16, 18] }
      expect(grade.grader_opts).to eq(expected)
    end
  end

  describe "#solution_set_options(day)" do
    let(:day)   { grade.days.first }

    before do
      grade.max_mds = 5
      grade.min_openers = 1
      grade.min_closers = 1
      grade.visits[day.to_s] = Array.new(28, 7)
      grade.normal = [0, 4, 8,  12, 16, 24]
      grade.max    = [0, 6, 12, 18, 24, 30]
    end

    it "should have the correct options" do
      expected = {open: grade.open_times[day.wday], close: grade.close_times[day.wday], max_mds: 4, min_openers: 3, min_closers: 3}
      expect(grade.solution_set_options(day)).to eq(expected)
    end

    it "should not return max_mds greater than the length of the speed vectors" do
      grade.normal = [0, 4, 8]
      grade.max    = [0, 6, 12]
      expect(grade.solution_set_options(day)[:max_mds]).to eq(2)
    end
  end

  describe "#build_solution_set(day)" do
    let(:day)   { grade.days.first }

    before do
      allow(grade).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 1, min_openers: 1, min_closers: 1})
    end

    it "should have the correct coverage list" do
      expected = [Array.new(28, 1)]
      expect(grade.build_solution_set(day)).to eq(expected)
    end
  end

  # Sanity test some private methods (these methods handle only visits level logic and might be extracted in the future)
  describe "private methods" do
    let(:visits) { grade.visits }
    let(:day)    { grade.days.first }

    describe "#day_max" do
      it "should return the max half hourly visitors" do
        visits[day.to_s][0] = 100
        expect(grade.send(:day_max, day)).to eq(100)
      end
    end

    describe "#am_min" do
      it "should return the max half hourly visitors" do
        visits[day.to_s][0] = 0.1
        visits[day.to_s][-1] = 0
        expect(grade.send(:am_min, day)).to eq(0.1)
      end
    end

    describe "#pm_min" do
      it "should return the max half hourly visitors" do
        visits[day.to_s][0] = 0
        visits[day.to_s][-1] = 0.1
        expect(grade.send(:pm_min, day)).to eq(0.1)
      end
    end
  end


  describe "Deleting a grade" do
    it "ensures that the location_plan has a chosen grade" do
      extra_grade = create(:grade, location_plan: location_plan)

      expect(location_plan.chosen_grade.id).to eql(grade.id)
      expect(location_plan.grades.count).to eql(2)

      grade.destroy

      expect(location_plan.reload.chosen_grade_id).to eql(extra_grade.id)
    end
  end

  describe "Cloning shifts" do
    before do
      3.times do |i|
        create(:shift, grade: grade)
      end
    end

    it "duplicates the shifts and their attributes" do
      expect(Shift.count).to eql(3)

      g = Grade.new(grade.attributes.except('id'))
      g.clone_shifts_from!(grade)

      expect(Shift.count).to eql(6)
    end
  end


  describe "#calculate_grade!" do

    it "should recalculate the breakdown and points" do
      date_s = grade.days.first.to_s

      exp_breakdown =       {
          queue: Array.new(29,0),
          seen: Array.new(28,2),
          turbo: Array.new(28,0),
          slack: Array.new(28,0),
          penalties: Array.new(29,0),
          penalty: 0
        }
      exp_points =      {
          total: 0,
          md_sat: 0,
          patient_sat: 0,
          cost: 0,
          hours: 14
        }

      grader = double(CoverageGrader)
      allow(grader).to receive(:full_grade).and_return([exp_breakdown, exp_points])
      grade.calculate_grade!(date_s, grader)
      expect(grade.breakdowns[date_s]).to eq(exp_breakdown)
      expect(grade.points[date_s]).to eq(exp_points)
    end
  end

  describe "#update_shift!" do
    let(:date)       { grade.days.first }
    let!(:old_shift) { create(:shift, starts_at: date.in_time_zone.beginning_of_day + 8.hours, grade: grade) }
    let!(:old_id)     { old_shift.id }
    let(:raw_shifts) { [{"id"=>612, "starts"=>8, "ends"=>12, "hours"=>4, "position_key"=>"md"}, {"id"=>613, "starts"=>12, "ends"=>20, "hours"=>8, "position_key"=>"md"}] }

    before { create(:position, key: :md) }

    specify { expect(grade.shifts.for_day(date).first).to eq(old_shift) } # verify old_shift belongs to grade

    describe "when called" do
      before { grade.update_shift!(date, raw_shifts) }

      it "should update shifts correctly" do
        act_shifts = grade.shifts.for_day(date)
        shift_1 = act_shifts.first
        shift_2 = act_shifts.second

        expect(act_shifts.size).to eq(2)
        expect(shift_1.starts_at).to eq(date.in_time_zone.beginning_of_day + 8.hours)
        expect(shift_1.ends_at).to eq(date.in_time_zone.beginning_of_day + 12.hours)
        expect(shift_2.starts_at).to eq(date.in_time_zone.beginning_of_day + 12.hours)
        expect(shift_2.ends_at).to eq(date.in_time_zone.beginning_of_day + 20.hours)
      end

      it "should update coverages correctly" do
        act_coverage = grade.coverages[date.to_s]
        expect(act_coverage).to eq(Array.new(24,1) + Array.new(4,0))
      end

      it "should delete any old shifts" do
        expect{ Shift.find(old_id) }.to raise_error ActiveRecord::RecordNotFound
      end
    end

  end

  describe "#over_staffed?" do
    let(:date)       { grade.days.first }
    let(:date_s)     { grade.days.first.to_s }

    context "when not overstaffed" do

      it "should return false" do
        max = grade.coverages[date_s].max
        expect(grade.normal.length - 1 >= max).to be(true)
        expect(grade.over_staffed?(date_s)).to eq(false)
      end

      it "#over_staffing_wasted_mins should return 0" do
        expect(grade.over_staffing_wasted_mins(date_s)).to eq(0)
      end
    end

    context "when overstaffed" do
      before do
        max = grade.coverages[date_s].max
        grade.normal = grade.normal[(0..(max-1))]
        grade.save!
      end

      it "should return true" do
        expect(grade.over_staffed?(date_s)).to eq(true)
      end

      it "#over_staffing_wasted_mins should return wasted mins" do
        expect(grade.over_staffing_wasted_mins(date_s)).to eq(14*60)
      end

      it "Analysis should have the right wasted time" do
        totals = Analysis.new(grade, date).totals
        s = totals[:slack]
        slack_mins = s / grade.normal[1] * 60
        expect(totals[:wasted_time]).to eq(14*60 + slack_mins )
      end
    end

  end
end
