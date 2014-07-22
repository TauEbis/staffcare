require 'spec_helper'

RSpec.describe Wiw::Shift, :type => :model do
  describe "Creating a shift in WIW" do
    it "saves the shift" do
      shift = create(:shift, starts_at: Time.zone.parse("2014-07-21T10:00:00-04:00"))
      wiw_shift = Wiw::Shift.build_from_shift(shift)

      VCR.use_cassette('shift_create') do
        r = wiw_shift.create
        expect(r.code).to eql(200)
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
end
