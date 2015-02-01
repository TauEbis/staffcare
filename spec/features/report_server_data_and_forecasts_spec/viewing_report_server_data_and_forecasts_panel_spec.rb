require 'spec_helper'

feature "Viewing the report server data and forecasts panel: " do

  subject { page }

  describe "Given a non-admin user visits report server data and forecasts page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit report_server_data_and_forecasts_path
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('Report Server Data &amp; Forecasts') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the report server data and forecasts page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit report_server_data_and_forecasts_path
		end

  	describe "then the index page is rendered:" do
			it { should have_title full_title('Report Server Data &amp; Forecasts') }
			it { should have_link('Visits', href: visits_path ) }
			it { should have_link('Heatmaps', href: heatmaps_path ) }
			it { should have_link('Volume Forecasts', href: patient_volume_forecasts_path ) }
		end
	end

end
