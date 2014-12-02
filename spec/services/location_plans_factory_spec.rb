require 'spec_helper'

describe LocationPlansFactory, :type => :service do

  let(:data_provider) 	{ DataProvider.new("database") }

	describe "#create" do

	  let!(:location) 			{ create(:location) }

		let(:schedule) 				{ create(:schedule) }
	  let(:factory)  				{ LocationPlansFactory.new(schedule: schedule, data_provider: data_provider) }
	  let(:projection)			{ create(:visit_projection, location: location, schedule: schedule) }

		before do
			allow(VisitProjection).to receive(:import!).and_return({ location.report_server_id => projection })
			factory.create
		end

		let(:lp) { schedule.location_plans.first }

		it "should load the correct locations" do
			expect(factory.instance_variable_get(:@locations)).to eq([location])
		end

		it "should copy the correct projections data" do
			expect(lp.visit_projection).to eq(projection)
			expect(lp.visits).to eq(projection.visits)
		end

		describe "should copy the correct location data" do

			it "for location attributes" do
				expect(lp.max_mds).to eq(location.max_mds)
				copied_fields = (LocationPlan::OPTIMIZER_FIELDS - [:open_times, :close_times]).map(&:to_s)
				expect(lp.attributes.slice(*copied_fields)).to eq(location.attributes.slice(*copied_fields))
			end

			it "for opening hours" do
				expect(lp.open_times).to eq(location.open_times)
				expect(lp.close_times).to eq(location.close_times)
			end

			it "for speeds" do
				expect(lp.normal).to eq([0] + location.speeds.map(&:normal))
				expect(lp.max).to eq([0] + location.speeds.map(&:max))
			end
		end

	end

	describe "#update" do

  	let!(:location) 			{ create(:location, max_mds: 10) }

		let(:schedule) 				{ create(:schedule) }
		let(:factory)  				{ LocationPlansFactory.new(schedule: schedule, data_provider: data_provider) }

		let!(:lp)					    {	create(:location_plan, schedule: schedule, location:location) }
		let!(:old_projection) { lp.visit_projection }
		let!(:old_max_mds)		{ lp.max_mds }
		let(:new_projection)	{ create(:visit_projection, location: location, schedule: schedule.reload) }

		before { allow(VisitProjection).to receive(:import!).and_return({ location.report_server_id => new_projection })}

		context "when opts['load_locations'] and opts['load_visits']" do

			before do
				opts = {'load_locations' => true, 'load_visits' => true }
				factory.update(opts)
				lp.reload
			end

			it "should load the correct locations" do
				expect(factory.instance_variable_get(:@locations)).to eq([location])
			end

			it "should update the projections data" do
				expect(lp.visit_projection).to eq(new_projection)
				expect(lp.visit_projection).not_to eq(old_projection)
			end

			it "should update the location data" do
				expect(lp.max_mds).to eq(location.max_mds)
				expect(lp.max_mds).not_to eq(old_max_mds)
			end

		end

		context "when opts['load_locations']" do

			before do
				opts = {'load_locations' => true, 'load_visits' => nil }
				factory.update(opts)
				lp.reload
			end

			it "should not update the projections data" do
				expect(lp.visit_projection).not_to eq(new_projection)
				expect(lp.visit_projection).to eq(old_projection)
			end

			it "should update the location data" do
				expect(lp.max_mds).to eq(location.max_mds)
				expect(lp.max_mds).not_to eq(old_max_mds)
			end

		end

		context "when opts['load_visits']" do

			before do
				opts = {'load_locations' => nil, 'load_visits' => true }
				factory.update(opts)
				lp.reload
			end

			it "should update the projections data" do
				expect(lp.visit_projection).to eq(new_projection)
				expect(lp.visit_projection).not_to eq(old_projection)
			end

			it "should not update the location data" do
				expect(lp.max_mds).not_to eq(location.max_mds)
				expect(lp.max_mds).to eq(old_max_mds)
			end

		end
	end
end