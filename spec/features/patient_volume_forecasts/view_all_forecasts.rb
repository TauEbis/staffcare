require 'spec_helper'

feature "Viewing all patient volume forecasts: " do

  subject { page }
  given(:locations)  { [ FactoryGirl.create(:location), FactoryGirl.create(:location) ] }

  describe "Given a non-admin user visits the index page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit patient_volume_forecasts_path
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('All patient volume forecasts') }
			it { should have_title full_title('Dashboard') }
		end

	end

  describe "Given am admin visits the index page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit patient_volume_forecasts_path
		end

  	describe "then the index page is rendered:" do
			it { should have_title full_title('All patient volume forecasts') }
		end

		context "when there are input_projections" do
			given!(:earlier_input_projection) { FactoryGirl.create(:patient_volume_forecast, start_date: Date.today, locations: locations) }
			given!(:later_input_projection) { FactoryGirl.create(:patient_volume_forecast, start_date: Date.today + 14, locations: locations) }
			background { visit current_path }

			it { should have_content(earlier_input_projection.start_date) }
			it { should have_content(later_input_projection.end_date) }
			it "should have the correct column names" do
				locations.map(&:name).each { |l_name| should have_content(l_name) }
			end

			it "then it should have the correct volume data" do
				locations.map(&:id).each do |l_id|
					volume = earlier_input_projection.volume_by_location[l_id.to_s]
					expect(volume).not_to be_nil
					expect(page).to have_content(volume)
				end
			end

			it "then the volume data should be in the descending order by start date" do
				expect(find('tr td', match: :first)).to have_content(later_input_projection.start_date)
			end

		end
	end
end
