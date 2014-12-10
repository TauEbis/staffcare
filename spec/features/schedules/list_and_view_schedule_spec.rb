require 'spec_helper'

feature "List & View schedules: " do

  subject { page }

	given(:admin) 		{ FactoryGirl.create(:admin_user) }
	given!(:schedule) { FactoryGirl.create(:schedule_with_children) }
	before { schedule.reload }

  describe "Given am admin visits the index page," do

		background do
			signin admin
			visit schedules_path
		end

  	describe "then the index page is rendered:" do
			it { should have_title full_title('All Schedules') }
			it { should have_content("State") }
		end

	end

  describe "Given am admin visits the show page," do

		before do
			signin admin
			visit schedule_path(schedule)
		end

  	describe "then the show page is rendered:" do
			it { should have_title full_title('Schedule for') }
			it { should have_content("wait mins") }
		end

		context "when a location_plan is still running" do
			before do
				schedule.grades.map(&:running!)
				visit schedule_path(schedule)
			end

			describe "then the schedule level anaysis is not rendered:" do
				it { should_not have_content("wait mins") }
			end
		end
	end

end
