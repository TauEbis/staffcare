require 'spec_helper'

RSpec.describe Visit, :type => :model do
  let (:visit) { FactoryGirl.build(:visit) }
  subject { visit }

# Validations
  it { should be_valid }

  context "when multiple visits exist for the same location and date" do
    before do
      location = visit.location
      date = visit.date
      FactoryGirl.create(:visit, date: date, location: location)
    end

    it {should_not be_valid}
  end

  pending "test custom validation: #valid_volumes"
  pending "test class method: ::totals_by_date_by_location"

  describe "#in_chunks" do
    vol =    { "08:00:00"=>0.0,
               "08:15:00"=>0.0,
               "08:30:00"=>0.0,
               "08:45:00"=>6.0,
               "09:00:00"=>3.0,
               "09:15:00"=>1.0,
               "09:30:00"=>2.0,
               "09:45:00"=>8.0 }

    it "should return chunked volumes" do
      visit.volumes = vol
      expect(visit.in_chunks(2)).to eq([6,14])
    end

    it "should return chunked volumes" do
      visit.volumes = vol
      expect(visit.in_chunks(4)).to eq([0,6,4,10])
    end
  end
end
