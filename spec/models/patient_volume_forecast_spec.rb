require 'spec_helper'

describe PatientVolumeForecast, :type => :model do
	let (:forecast) { FactoryGirl.build(:patient_volume_forecast) }
	subject { forecast}

# Attributes
	it { should respond_to(:start_date) }
	it { should respond_to(:end_date) }
	it { should respond_to(:volume_by_location) }

# Validations
	it { should be_valid }

	context "when start_date is not present" do
		before { forecast.start_date = nil }
		it {should_not be_valid}
	end

  context "when end_date is not present" do
    before { forecast.end_date = nil }
    it { should_not be_valid }
  end

  context "when volume_by_location is not present" do
    before { forecast.volume_by_location = nil }
    it { should_not be_valid }
  end

# Scope
  describe "scope" do
    sunday = Date.parse('2014-07-06')
		let!(:earlier_projection) { FactoryGirl.create(:patient_volume_forecast, start_date: sunday) }
		let!(:later_projection_1) { FactoryGirl.create(:patient_volume_forecast, start_date: sunday + 7) }
		let!(:later_projection_2) { FactoryGirl.create(:patient_volume_forecast, start_date: sunday + 14) }


    describe "ordered" do
      it "should be in descending order by start date and then id" do
        expect(PatientVolumeForecast.ordered.to_a).to eq [later_projection_2, later_projection_1, earlier_projection]
      end
    end

    describe "default" do
      it "should be in descending order by start date and then id" do
        expect(PatientVolumeForecast.ordered.to_a).to eq [later_projection_2, later_projection_1, earlier_projection]
      end
    end
  end

end
