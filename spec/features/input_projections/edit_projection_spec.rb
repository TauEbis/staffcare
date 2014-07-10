require 'spec_helper'

feature "Editing an input projections " do

  subject { page }
  given(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
	given!(:input_projection) { FactoryGirl.create(:input_projection, locations: locations) }

  describe "Given a non-admin user visits the edit_input_projection page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit edit_input_projection_path(input_projection)
		end

  	describe "then the edit page is not rendered:" do
			it { should_not have_title full_title('Edit input projection') }
			it { should have_title full_title('Dashboard') }
		end

	end

  describe "Given am admin visits the edit_input_projection page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit edit_input_projection_path(input_projection)
		end

  	describe "then the edit page is rendered:" do
			it { should have_title full_title('Edit input projection') }
			it { should have_content 'Update the projections' }
		end

		context "when valid information is submitted" do
      given(:valid_info) { FactoryGirl.build(:input_projection, locations: locations) }
      background do
        edit_input_projection(valid_info, locations, submit: true)
        input_projection.reload
      end

			it { should have_success_message('Input Projection was successfully updated.') }
			it { should have_title full_title('All input projections') }

      describe "then the input projection is updated" do
				specify { expect(input_projection.start_date).to eq valid_info.start_date }
    		specify { expect(input_projection.end_date).to eq valid_info.end_date }
    		specify { expect(input_projection.volume_by_location).to eq valid_info.volume_by_location }
  		end
    end

    context "when invalid information is submitted" do
    	given(:invalid_info) { FactoryGirl.build(:input_projection, end_date: nil, locations: locations) }
    	background do
        edit_input_projection(invalid_info, locations, submit: true)
        input_projection.reload
    	end

			it { should have_title full_title('Edit input projection') }
			it { should have_error_message 'blank' }

    	describe "then the input projection is not updated" do

	    	specify { expect(input_projection.start_date).not_to eq invalid_info.start_date }
	    	specify { expect(input_projection.end_date).not_to eq invalid_info.end_date }
    		specify { expect(input_projection.volume_by_location).not_to eq invalid_info.volume_by_location }
	    end

	  end
	end

end