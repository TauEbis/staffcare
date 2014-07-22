require 'spec_helper'

RSpec.describe Wiw::Shift, :type => :model do
  describe "Creating a shift in WIW" do
    it "saves the shift" do
      shift = create(:shift, starts_at: Time.zone.parse("2014-07-21T10:00:00-04:00"))
      wiw_shift = Wiw::Shift.build_from_shift(shift)

      VCR.use_cassette('shift_create') do
        response = wiw_shift.create
        expect(response.code).to eql(200)
        expect(response['shift']['id']).to eql(42448351)
      end
    end
  end

  describe "Updating a shift in WIW" do
    it "saves the shift" do
      shift = create(:shift, starts_at: Time.zone.parse("2014-07-22T10:00:00-04:00"), wiw_id: 42537130)
      wiw_shift = Wiw::Shift.build_from_shift(shift)

      VCR.use_cassette('shift_update') do
        r = wiw_shift.update
        expect(r.code).to eql(200)
      end
    end
  end

  describe "Deleting a shift in WIW" do
    it "deletes the shift" do
      shift = create(:shift, wiw_id: 42537379)
      wiw_shift = Wiw::Shift.build_from_shift(shift)

      VCR.use_cassette('shift_delete') do
        r = wiw_shift.delete
        expect(r.code).to eql(200)
      end
    end
  end

  describe "Listing shifts in WIW" do
    let(:schedule) { create(:schedule, starts_on: Date.parse("2014-07-01")) }
    let(:location_plan) { create(:location_plan, schedule: schedule) }

    it "returns all the shifts" do
      VCR.use_cassette('shift_list_location_plan') do
        results = Wiw::Shift.find_all_for_location_plan(location_plan)

        expect(results.length).to eql(2)
        expect(results[0].id).to eql(40210383)
      end
    end
  end
end
