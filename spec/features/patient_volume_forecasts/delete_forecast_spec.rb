require 'spec_helper'

feature "Deleting a patient volume forecast: " do

  subject { page }
  given(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
	given!(:earlier_input_projection) { FactoryGirl.create(:patient_volume_forecast, start_date: Date.today, locations: locations) }
	given!(:later_input_projection) { FactoryGirl.create(:patient_volume_forecast, start_date: Date.today + 14, locations: locations) }

  describe "Given am admin visits the index page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit patient_volume_forecasts_path
		end

		it { should have_link('Delete', href: patient_volume_forecast_path(earlier_input_projection) ) }

		scenario "when he clicks a delete link, then it deletes an Patient Volume Forecast" do
			expect { click_link('Delete', match: :first) }.to change(PatientVolumeForecast, :count).by(-1)
		end

		context "when he clicks the delete link" do
			background { click_link('Delete', match: :first) }
			it { should have_title full_title('All patient volume forecasts') }
			it { should have_success_message('Patient Volume Forecast was successfully destroyed.') }
		end

	end
end
