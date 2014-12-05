require 'spec_helper'

describe Grade, :type => :model do
  let (:location_plan) { create(:location_plan) }
	let (:grade)         { location_plan.chosen_grade }

  it "comes out of the factory correctly" do
    expect(grade.location_plan.chosen_grade).to eql(grade)
  end


  describe "Deleting a grade" do
    it "ensures that the location_plan has a chosen grade" do
      extra_grade = create(:grade, location_plan: location_plan)

      expect(location_plan.chosen_grade).to eql(grade)
      expect(location_plan.grades.count).to eql(2)

      grade.destroy

      expect(location_plan.reload.chosen_grade).to eql(extra_grade)
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
      date_s = location_plan.days.first.to_s

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
    let(:date)       { location_plan.days.first }
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

    let(:date_s) { location_plan.days.first.to_s }

    context "when not overstaffed" do

      it "should return false" do
        max = grade.coverages[date_s].max
        expect(location_plan.normal.length - 1 >= max).to be(true)
        expect(grade.over_staffed?(date_s)).to eq(false)
      end
    end

    context "when overstaffed" do
      before do
        max = grade.coverages[date_s].max
        location_plan.normal = location_plan.normal[(0..(max-2))]
        location_plan.save
      end

      it "should return true" do
        expect(grade.over_staffed?(date_s)).to eq(true)
      end
    end

  end
end
