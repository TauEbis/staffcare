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

end
