require 'spec_helper'

feature "Creating an input projections " do

  subject { page }
  given!(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
  given(:submit) 			{ "Create Input projection" }

  describe "Given a non-admin user visits the new input projection page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit new_input_projection_path
		end

  	describe "then the new page is not rendered:" do
			it { should_not have_title full_title('New input projection') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the new input projection page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit new_input_projection_path
		end

  	describe "then the new page is rendered:" do
			it { should have_title full_title('New input projection') }
			it { should have_content 'New Input Projection' }
		end

		context "when valid information is entered" do
      given(:valid_info) { FactoryGirl.build(:input_projection, locations: locations) }
      background { new_input_projection(valid_info, locations, submit: false) }

    	scenario "and submitted then an input projection is created" do
	    	expect { click_button submit }.to change(InputProjection, :count).by(1)
			end

			context "and submitted" do
				background { click_button submit }

		    it { should have_success_message('Input Projection was successfully created.') }
		    it { should have_title full_title('All input projections') }
				it { should have_content valid_info.start_date }
			end

    end

    context "when invalid information is entered" do
    	scenario "and submitted then a user is not created" do
	    	expect { click_button submit }.not_to change(InputProjection, :count)
			end

			context "and submitted" do
				background { click_button submit }
				it { should have_error_message('blank') }
				it { should have_title full_title('New input projection') }
			end

    end
	end
end
