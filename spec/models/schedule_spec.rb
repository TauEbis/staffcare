require 'spec_helper'

describe Schedule, :type => :model do
  let(:schedule) { create(:schedule_with_children) }

	subject { schedule }

	before { schedule.reload }

  describe "#lps_complete?" do
  	before { schedule.grades.map(&:complete!) }

  	context "when a location plan is still running" do
	  	before { schedule.grades.first.running! }

			it "should return false" do
				expect(schedule.lps_complete?).to eq(false)
			end
		end

		context "when a schedule has no location_plans" do
	  	before { schedule.location_plans.delete_all }

			it "should return false" do
				expect(schedule.lps_complete?).to eq(false)
			end
		end

		context "when all location plans are complete" do
			it "should return true" do
				expect(schedule.lps_complete?).to eq(true)
			end
		end
  end

  describe "#zone_complete?" do
  	let(:zone) {schedule.zones.first}

  	before { schedule.grades.for_zone(zone).map(&:complete!) }

  	context "when a location plan in the zone is still running" do
	  	before { schedule.grades.for_zone(zone).first.running! }

			it "should return false" do
				expect(schedule.zone_complete?(zone)).to eq(false)
			end
		end

  	context "when a zone has no location_plans" do
	  	before { schedule.location_plans.for_zone(zone).delete_all }

			it "should return false" do
				expect(schedule.zone_complete?(zone)).to eq(false)
			end
		end

		context "when all location plans in the zone are complete" do
			it "should return true" do
				expect(schedule.zone_complete?(zone)).to eq(true)
			end
		end
  end

end
