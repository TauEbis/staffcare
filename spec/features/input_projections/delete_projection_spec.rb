require 'spec_helper'

feature "Deleting an input projections: " do

  subject { page }
  given(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }
	given!(:earlier_input_projection) { FactoryGirl.create(:input_projection, start_date: Date.today, locations: locations) }
	given!(:later_input_projection) { FactoryGirl.create(:input_projection, start_date: Date.today + 14, locations: locations) }

  describe "Given am admin visits the index page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit input_projections_path
		end

		it { should have_link('Delete', href: input_projection_path(earlier_input_projection) ) }

		scenario "when he clicks a delete link, then it deletes an Input Projection" do
			expect { click_link('Delete', match: :first) }.to change(InputProjection, :count).by(-1)
		end

		context "when he clicks the delete link" do
			background { click_link('Delete', match: :first) }
			it { should have_title full_title('All input projections') }
			it { should have_success_message('Input Projection was successfully destroyed.') }
		end

	end
end
