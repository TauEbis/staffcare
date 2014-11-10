require 'spec_helper'

describe LocationPlanOptimizer, :type => :service do

  let(:location_plan) { create(:location_plan) }
  let(:lp_optimizer)  { LocationPlanOptimizer.new(location_plan) }

  let(:dummy_shift)		{ build(:shift)}
  let(:dummy_grade)		{ dummy_shift.grade }

	describe "#optimize!" do
		before do
			Position.create_key_positions

			allow(location_plan.schedule).to receive(:days).and_return([Date.today])

			loader = double(SpeedySolutionSetLoader)
			allow(loader).to receive(:load).and_return([])
			lp_optimizer.instance_variable_set("@loader", loader)

			picker = double(CoveragePicker)
			allow(picker).to receive(:pick_best).and_return([dummy_grade.coverages.values.first, dummy_grade.breakdowns.values.first, dummy_grade.points.values.first])
			lp_optimizer.instance_variable_set("@picker", picker)

			sc = double(ShiftCoverage)
			allow(sc).to receive(:coverage_to_shifts).and_return([dummy_shift])
			lp_optimizer.instance_variable_set("@sc", sc)

			lp_optimizer.optimize!
		end

  	let(:grade) {location_plan.grades.first}

		it "it will create a grade and make it choosen and more" do
			expect(location_plan.grades.size).to eq(1)

			expect(grade.coverages.values.first).to eq(dummy_grade.coverages.values.first)
			expect(grade.breakdowns.values.first).to eq(dummy_grade.breakdowns.values.first)
			expect(grade.points.values.first).to eq(dummy_grade.points.values.first)

			expect(grade.shifts.md.map(&:starts_at)).to eq([dummy_shift.starts_at])
			expect(grade).to eq(location_plan.chosen_grade)
		end

		describe "#create_non_md_shifts!" do

			before do
				Rule.create_default_template

				#gen = double(LineWorkerShiftGenerator)
				#allow(gen).to receive(:create!).and_return([])
				#lp_optimizer.instance_variable_set("@gen", gen)

				lp_optimizer.create_non_md_shifts!
			end

			it "should geerate shifts for the 4 line worker positions" do
				expect(grade.shifts.line_workers.map(&:position).uniq.size).to eq(4)
			end

		end
	end

end