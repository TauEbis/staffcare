require 'spec_helper'

feature "Viewing the staffing analyst panel: " do

  subject { page }

  describe "Given a non-admin user visits the staffing analyst page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit staffing_analyst_path
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('Staffing Analyst') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the staffing analyst page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		background do
			signin admin
			visit staffing_analyst_path
		end

  	describe "then the index page is rendered:" do
			it { should have_title full_title('Staffing Analyst') }
			it { should have_link('Non-physician rules', href: default_rules_path ) }
			it { should have_link('Positions', href: positions_path ) }
			it { should have_link('Heatmaps', href: heatmaps_path ) }
			it { should have_link('Volume Forecasts', href: patient_volume_forecasts_path ) }
			it { should have_link('Life Cycles', href: life_cycles_path ) }
		end
	end

end
