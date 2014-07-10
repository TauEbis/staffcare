require 'spec_helper'

describe "Authorization " do

	describe "As a signed-out user" do

		context "when I submit a POST request to the InputProjections#create action" do
			let(:projection) { FactoryGirl.build(:input_projection) }
			let(:params) { { input_projection: { start_date: projection.start_date, end_date: projection.end_date,
																					 volume_by_location: projection.volume_by_location } } }
			before { post input_projections_path params }
			specify { expect(response).to redirect_to(new_user_session_url) }
		end

		context "when I submit a PATCH request to a InputProjections#update action" do
			let!(:projection) { FactoryGirl.create(:input_projection) }
			let(:update) { FactoryGirl.build(:input_projection) }
			let(:params) { { input_projection: { start_date: update.start_date, end_date: update.end_date,
																					 volume_by_location: update.volume_by_location } } }
			before { patch input_projection_path(projection, params) }
			specify { expect(response).to redirect_to(new_user_session_url) }
		end

		context "when I submit a DELETE request to a InputProjections#destroy action" do
			let!(:projection) { FactoryGirl.create(:input_projection) }
			before { delete input_projection_path projection }

			specify { expect(response).to redirect_to(new_user_session_url) }
		end
	end

	describe "As a signed-in user" do
		let(:user) { FactoryGirl.create(:user) } # if set to admin_user all tests fail as expected
		before { signin(user, no_capybara: true) }

		context "when I submit a POST request to the InputProjections#create action" do
			let(:projection) { FactoryGirl.build(:input_projection) }
			let(:params) { { input_projection: { start_date: projection.start_date, end_date: projection.end_date,
																					 volume_by_location: projection.volume_by_location } } }
			before { post input_projections_path params }
			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully created.') }
		end

		context "when I submit a PATCH request to a InputProjections#update action" do
			let!(:projection) { FactoryGirl.create(:input_projection) }
			let(:update) { FactoryGirl.build(:input_projection) }
			let(:params) { { input_projection: { start_date: update.start_date, end_date: update.end_date,
																					 volume_by_location: update.volume_by_location } } }
			before { patch input_projection_path(projection, params) }
			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully updated.') }
		end

		context "when I submit a DELETE request to a InputProjections#destroy action" do
			let!(:projection) { FactoryGirl.create(:input_projection) }
			before { delete input_projection_path projection }

			specify { expect(response).to redirect_to(root_url) }
			specify { expect(flash[:notice]).not_to eq('Input Projection was successfully destroyed.') }
		end

	end
end