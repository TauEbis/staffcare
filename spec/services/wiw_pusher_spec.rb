require 'spec_helper'

describe WiwPusher, :type => :service do
  let(:location_plan) { create(:location_plan) }
  let(:shift) { create(:shift, grade: location_plan.chosen_grade) }
  let(:wiw_pusher)    { WiwPusher.new(location_plan) }
  subject { wiw_pusher }

  describe "Planning how to sync" do

    it "decides to create a new shift" do
      Wiw::Shift.stub(:find_all_for_location_plan).and_return([])

      expected = [ Wiw::Shift.build_from_shift(shift) ]

      expect(wiw_pusher.creates).to eql(expected)
    end

    it "decides to update an existing shift" do
      existing_remote = Wiw::Shift.new({'id' => 1})
      shift.update_attribute(:wiw_id, 1)

      Wiw::Shift.stub(:find_all_for_location_plan).and_return([existing_remote])

      expected = [ Wiw::Shift.build_from_shift(shift) ]

      expect(wiw_pusher.updates).to eql(expected)
    end

    it "decides to delete a shift that shouldn't exist" do
      existing_remote = Wiw::Shift.new({'id' => 1})
      Wiw::Shift.stub(:find_all_for_location_plan).and_return([existing_remote])
      expected = [ existing_remote ]

      expect(wiw_pusher.deletes).to eql(expected)
    end
  end
end
