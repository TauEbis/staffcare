require 'spec_helper'

describe "Authorization " do

	describe "As a signed-out user" do

		context "when I submit a POST request to the InputProjections#create action" do
			let(:projection) { FactoryGirl.build(:patient_volume_forecast) }
			let(:params) { { patient_volume_forecast: { start_date: projection.start_date, end_date: projection.end_date,
																					 volume_by_location: projection.volume_by_location } } }
			before { post patient_volume_forecasts_path params }
			specify { expect(response).to redirect_to(new_user_session_url) }
		end

		context "when I submit a PATCH request to a InputProjections#update action" do
			let!(:projection) { FactoryGirl.create(:patient_volume_forecast) }
			let(:update) { FactoryGirl.build(:patient_volume_forecast) }
			let(:params) { { patient_volume_forecast: { start_date: update.start_date, end_date: update.end_date,
																					 volume_by_location: update.volume_by_location } } }
			before { patch patient_volume_forecast_path(projection, params) }
			specify { expect(response).to redirect_to(new_user_session_url) }
		end

		context "when I submit a DELETE request to a InputProjections#destroy action" do
			let!(:projection) { FactoryGirl.create(:patient_volume_forecast) }
			before { delete patient_volume_forecast_path projection }

			specify { expect(response).to redirect_to(new_user_session_url) }
		end
	end

	describe "As a signed-in user" do
		let(:user) { FactoryGirl.create(:user) } # if set to admin_user all tests fail as expected
		before { signin(user, no_capybara: true) }

		context "when I submit a POST request to the InputProjections#create action" do
			let(:projection) { FactoryGirl.build(:patient_volume_forecast) }
			let(:params) { { patient_volume_forecast: { start_date: projection.start_date, end_date: projection.end_date,
																					 volume_by_location: projection.volume_by_location } } }
			before { post patient_volume_forecasts_path params }
			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully created.') }
		end

		context "when I submit a PATCH request to a InputProjections#update action" do
			let!(:projection) { FactoryGirl.create(:patient_volume_forecast) }
			let(:update) { FactoryGirl.build(:patient_volume_forecast) }
			let(:params) { { patient_volume_forecast: { start_date: update.start_date, end_date: update.end_date,
																					 volume_by_location: update.volume_by_location } } }
			before { patch patient_volume_forecast_path(projection, params) }
			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully updated.') }
		end

		context "when I submit a DELETE request to a InputProjections#destroy action" do
			let!(:projection) { FactoryGirl.create(:patient_volume_forecast) }
			before { delete patient_volume_forecast_path projection }

			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully destroyed.') }
		end

	end
end
