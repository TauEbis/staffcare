require 'spec_helper'

feature "Viewing and editing positions: " do

  subject { page }

  describe "Given a non-admin user visits the index page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit positions_path
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('All positions') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the index page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			Position.create_key_positions
			signin admin
			visit positions_path
		end

  	describe "then the index page is rendered:" do
			it { should have_title full_title('All Positions') }
			it { should have_content("Medical Assistant") }
			it { should have_content("Physician") }
			it { should have_content("180") }
		end
	end

	describe "Given a non-admin user visits the edit page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit edit_position_path(FactoryGirl.create(:position))
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('All positions') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the edit page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			Position.create_key_positions
			signin admin
			VCR.use_cassette('list_positions_on_edit') do
				visit edit_position_path(Position.find_by(key: :ma))
			end
		end

  	describe "then the edit page is rendered:" do
				it { should have_title full_title('Edit Position') }
				it { should have_content("Medical Assistant") }
				it { should have_content("Hourly rate") }
		end

		context "when valid information is submitted" do
      background do
        fill_in "Hourly rate", 						with: 25
        VCR.use_cassette('list_positions_on_edit') do
        	click_button "Update Position"
        end
      end

			it { should have_success_message('Position was successfully updated.') }
			it { should have_title full_title('All Positions') }
			it { should have_content '25' }
		end

    context "when invalid information is submitted" do
      background do
        fill_in "Hourly rate", 						with: 'a'
        VCR.use_cassette('list_positions_on_edit') do
        	click_button "Update Position"
        end
      end

			it { should have_title full_title('Edit Position') }
			it { should have_error_message '' }
	  end

	end

end
