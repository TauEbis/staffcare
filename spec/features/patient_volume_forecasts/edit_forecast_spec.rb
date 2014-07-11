require 'spec_helper'

feature "Editing an input projections " do

  subject { page }
  given(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
	given!(:patient_volume_forecast) { FactoryGirl.create(:patient_volume_forecast, locations: locations) }

  describe "Given a non-admin user visits the edit_patient_volume_forecast page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit edit_patient_volume_forecast_path(patient_volume_forecast)
		end

  	describe "then the edit page is not rendered:" do
			it { should_not have_title full_title('Edit patient volume forecast') }
			it { should have_title full_title('Dashboard') }
		end

	end

  describe "Given am admin visits the edit_patient_volume_forecast page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit edit_patient_volume_forecast_path(patient_volume_forecast)
		end

  	describe "then the edit page is rendered:" do
			it { should have_title full_title('Edit patient volume forecast') }
			it { should have_content 'Update patient volume forecast' }
		end

		context "when valid information is submitted" do
      given(:valid_info) { FactoryGirl.build(:patient_volume_forecast, locations: locations) }
      background do
        edit_patient_volume_forecast(valid_info, locations, submit: true)
        patient_volume_forecast.reload
      end

			it { should have_success_message('Patient Volume Forecast was successfully updated.') }
			it { should have_title full_title('All patient volume forecasts') }

      describe "then the input projection is updated" do
				specify { expect(patient_volume_forecast.start_date).to eq valid_info.start_date }
    		specify { expect(patient_volume_forecast.end_date).to eq valid_info.end_date }
    		specify { expect(patient_volume_forecast.volume_by_location).to eq valid_info.volume_by_location }
  		end
    end

    context "when invalid information is submitted" do
    	given(:invalid_info) { FactoryGirl.build(:patient_volume_forecast, end_date: nil, locations: locations) }
    	background do
        edit_patient_volume_forecast(invalid_info, locations, submit: true)
        patient_volume_forecast.reload
    	end

			it { should have_title full_title('Edit patient volume forecast') }
			it { should have_error_message 'blank' }

    	describe "then the input projection is not updated" do

	    	specify { expect(patient_volume_forecast.start_date).not_to eq invalid_info.start_date }
	    	specify { expect(patient_volume_forecast.end_date).not_to eq invalid_info.end_date }
    		specify { expect(patient_volume_forecast.volume_by_location).not_to eq invalid_info.volume_by_location }
	    end

	  end
	end

end
