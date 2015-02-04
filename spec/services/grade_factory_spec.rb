require 'spec_helper'

describe GradeFactory, :type => :service do

	describe "#create" do

	  let!(:location) 			{ create(:location) }

		let(:schedule) 				{ create(:schedule) }
	  let(:factory)  				{ GradeFactory.new(schedule: schedule, volume_source: :patient_volume_forecasts) }
	  let(:projection)			{ create(:visit_projection, location: location, schedule: schedule) }

		before do
			allow(factory.builder).to receive(:build_projection!).and_return( projection )
			factory.create
		end

		let(:grade) { schedule.grades.first }

		it "should load the correct locations" do
			expect(factory.instance_variable_get(:@locations)).to eq([location])
		end

		it "should copy the correct projections data" do
			expect(grade.visit_projection).to eq(projection)
			expect(grade.visits).to eq(projection.visits)
		end

		describe "should copy the correct location data" do

			it "for location attributes" do
				expect(grade.max_mds).to eq(location.max_mds)
				copied_fields = (Grade::OPTIMIZER_FIELDS - [:open_times, :close_times]).map(&:to_s)
				expect(grade.attributes.slice(*copied_fields)).to eq(location.attributes.slice(*copied_fields))
			end

			it "for opening hours" do
				expect(grade.open_times).to eq(location.open_times)
				expect(grade.close_times).to eq(location.close_times)
			end

			it "for speeds" do
				expect(grade.normal).to eq([0] + location.speeds.map(&:normal))
				expect(grade.max).to eq([0] + location.speeds.map(&:max))
			end
		end

	end

	describe "#update" do

  	let!(:location) 			{ create(:location, max_mds: 10) }

		let(:schedule) 				{ create(:schedule) }
		let(:factory)  				{ GradeFactory.new(schedule: schedule, volume_source: :patient_volume_forecasts) }

		let!(:grade)					{	create(:grade, schedule: schedule, location: location) }
		let!(:old_projection) { grade.visit_projection }
		let!(:old_max_mds)		{ grade.max_mds }
		let(:new_projection)	{ create(:visit_projection, location: location, schedule: schedule.reload) }

		before { allow(factory.builder).to receive(:build_projection!).and_return(new_projection) }

		context "when opts['load_locations'] and opts['load_visits']" do

			before do
				opts = {'load_locations' => true, 'load_visits' => true }
				factory.update(opts)
				grade.reload
			end

			it "should load the correct locations" do
				expect(factory.instance_variable_get(:@locations)).to eq([location])
			end

			it "should update the projections data" do
				pending "GradeFactory#update must be re-evaluated"
				expect(grade.visit_projection).to eq(new_projection)
				expect(grade.visit_projection).not_to eq(old_projection)
			end

			it "should update the location data" do
				pending "GradeFactory#update must be re-evaluated"
				expect(grade.max_mds).to eq(location.max_mds)
				expect(grade.max_mds).not_to eq(old_max_mds)
			end

		end

		context "when opts['load_locations']" do

			before do
				opts = {'load_locations' => true, 'load_visits' => nil }
				factory.update(opts)
				grade.reload
			end

			it "should not update the projections data" do
				expect(grade.visit_projection).not_to eq(new_projection)
				expect(grade.visit_projection).to eq(old_projection)
			end

			it "should update the location data" do
				pending "GradeFactory#update must be re-evaluated"
				expect(grade.max_mds).to eq(location.max_mds)
				expect(grade.max_mds).not_to eq(old_max_mds)
			end

		end

		context "when opts['load_visits']" do

			before do
				opts = {'load_locations' => nil, 'load_visits' => true }
				factory.update(opts)
				grade.reload
			end

			it "should update the projections data" do
				pending "GradeFactory#update must be re-evaluated"
				expect(grade.visit_projection).to eq(new_projection)
				expect(grade.visit_projection).not_to eq(old_projection)
			end

			it "should not update the location data" do
				expect(grade.max_mds).not_to eq(location.max_mds)
				expect(grade.max_mds).to eq(old_max_mds)
			end

		end
	end
end
