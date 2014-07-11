require 'spec_helper'

feature "Creating a patient volume forecast " do

  subject { page }
  given!(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
  given(:submit) 			{ "Create Patient volume forecast" }

  describe "Given a non-admin user visits the new input projection page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit new_patient_volume_forecast_path
		end

  	describe "then the new page is not rendered:" do
			it { should_not have_title full_title('New patient volume forecast') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the new input projection page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit new_patient_volume_forecast_path
		end

  	describe "then the new page is rendered:" do
			it { should have_title full_title('New patient volume forecast') }
			it { should have_content 'New Patient Volume Forecast' }
		end

		context "when valid information is entered" do
      given(:valid_info) { FactoryGirl.build(:patient_volume_forecast, locations: locations) }
      background { new_patient_volume_forecast(valid_info, locations, submit: false) }

    	scenario "and submitted then an input projection is created" do
	    	expect { click_button submit }.to change(PatientVolumeForecast, :count).by(1)
			end

			context "and submitted" do
				background { click_button submit }

		    it { should have_success_message('Patient volume forecast was successfully created.') }
		    it { should have_title full_title('All patient volume forecasts') }
				it { should have_content valid_info.start_date }
			end

    end

    context "when invalid information is entered" do
    	scenario "and submitted then a user is not created" do
	    	expect { click_button submit }.not_to change(PatientVolumeForecast, :count)
			end

			context "and submitted" do
				background { click_button submit }
				it { should have_error_message('blank') }
				it { should have_title full_title('New patient volume forecast') }
			end

    end
	end
end
