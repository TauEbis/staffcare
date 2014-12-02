require 'spec_helper'

describe SpeedySolutionSetLoader, :type => :service do

	let(:location_plan) { FactoryGirl.create(:location_plan) }
	let(:day_1) 				{ location_plan.days.first }
	let(:day_2) 				{ location_plan.days.second }
	let(:day_3) 				{ location_plan.days.third }
	let(:loader) 				{ SpeedySolutionSetLoader.new }

	before do
		@counter = 0
		allow(location_plan).to receive(:build_solution_set) { |day| @counter +=1 }
	end

	describe "cacheing the options" do
		before do
			allow(location_plan).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 2, min_openers: 2, min_closers: 2})
			loader.load(location_plan, day_1)
			allow(location_plan).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 1, min_openers: 1, min_closers: 1})
			loader.load(location_plan, day_2)
			loader.load(location_plan, day_3)
		end

		it "should only hits the builder once for each set of options" do
			expect(@counter).to eq(2)
		end

		it "correctly hashes the results" do
			expect(loader.instance_variable_get(:@_loaded_solution_sets).keys.size).to eq(2)
		end
	end

	describe "returning the correct value" do
		it "should return the value returned by the solution set builder" do
			allow(location_plan).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 2, min_openers: 2, min_closers: 2})
			expect(loader.load(location_plan, day_1)).to eq(1)
			allow(location_plan).to receive(:solution_set_options).and_return({open: 8, close: 22, max_mds: 1, min_openers: 1, min_closers: 1})
			expect(loader.load(location_plan, day_2)).to eq(2)
			expect(loader.load(location_plan, day_3)).to eq(2)
		end
	end

end