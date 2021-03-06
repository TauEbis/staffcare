require 'spec_helper'

describe GradeOptimizer, :type => :service do

	let(:schedule) { create(:schedule) }
  let(:grade) { create(:grade, schedule: schedule) }
  let(:optimizer)  { GradeOptimizer.new(grade) }

	describe "#optimize!" do
	  let(:dummy_shift)		{ build(:shift) }
    let(:dummy_grade)		{ dummy_shift.grade }
  	# let(:grade) { location_plan.grades.first }

		before do
			Position.create_key_positions

			allow(grade.schedule).to receive(:days).and_return([Date.today])
			allow(optimizer.loader).to receive(:load).and_return([])
			allow(optimizer.picker).to receive(:pick_best).and_return([dummy_grade.coverages.values.first, dummy_grade.breakdowns.values.first, dummy_grade.points.values.first])
			allow(optimizer.sc).to receive(:coverage_to_shifts).and_return([dummy_shift])

			optimizer.optimize!
		end

		it "it will create a grade and make it chosen" do
			pending "All chosen stuff needs to be fixed"
			expect(schedule.grades.size).to eq(1)
			expect(grade).to eq(location_plan.chosen_grade)
		end

		it "it will create the correct coverages" do
			expect(grade.coverages.values.first).to eq(dummy_grade.coverages.values.first)
		end

		it "it will create the correct breakdowns" do
			expect(grade.breakdowns.values.first).to eq(dummy_grade.breakdowns.values.first)
		end

		it "it will create the correct points" do
			expect(grade.points.values.first).to eq(dummy_grade.points.values.first)
		end

		it "it will create the correct shifts" do
			expect(grade.shifts.md.map(&:starts_at)).to eq([dummy_shift.starts_at])
		end

	end

	describe "#create_non_md_shifts!" do

		let!(:grade) { create(:grade) }

		before do
			create(:shift, grade: grade) # md shift is default
			create(:rule, name: :ratio_1, position: create(:position, key: :ma), grade: grade)

			allow(Rule).to receive(:create_default_template).and_return(nil)

			optimizer.create_non_md_shifts!(grade)
		end

		it "should generate the correct line_worker shifts" do
			expect(grade.shifts.line_workers.count).to eq(1) # ratio_1 for the 1 md shift
		end

	end

end
