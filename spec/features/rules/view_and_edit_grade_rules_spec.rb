require 'spec_helper'

feature "Viewing and editing grade specific rules: " do

  subject { page }

  describe "Given a non-admin user visits the grade rules page," do
		given(:user)  { FactoryGirl.create(:user) }
		given(:grade) { FactoryGirl.create(:grade) }

		background do
			Position.create_key_positions
			Rule.create_default_template
			Rule.copy_template_to_grade(grade)
		end

		context "when the user did not create the grade" do

			background do
				signin user
				visit rules_grade_path(grade)
			end

	  	describe "then the page is not rendered:" do
				it { should_not have_title full_title('Edit Default Rules') }
				it { should have_title full_title('Dashboard') }
			end
		end

		context "when the user created the grade and is associated with the location" do

			background do
				user.locations << grade.location_plan.location
				grade.manual!
				user.grades << grade
				signin user
				visit rules_grade_path(grade)
			end

	  	describe "then the page is rendered:" do
				it { should have_title full_title('Edit Default Rules') }
				it { should_not have_title full_title('Dashboard') }
				it { should have_content("Position") }
				it { should have_content("Rule") }
				it { should have_content("Single Coverage") }
			end
		end
	end

	describe "Given a non-admin user visits the edit page of a rule for a grade they created," do
		given(:user) { FactoryGirl.create(:user) }
		given(:grade) { FactoryGirl.create(:grade, user: user, source: :manual) }
		given(:rule) { FactoryGirl.create(:rule, name: "limit_1", position: create(:position, key: :ma), grade: grade) }

		background do
			user.locations << grade.location_plan.location
			signin user
			visit edit_rule_path(rule)
		end

  	describe "then the edit page is rendered:" do
			it { should have_title full_title('Edit Rule') }
			it { should have_select('rule_name', selected: 'Single Coverage') }
		end

		context "when valid information is submitted" do
      background do
        select "Double Coverage", 						from: 'Name'
				click_button "Update Rule"
      end

			it { should have_success_message('Rule was successfully updated.') }
			it { should have_title full_title('Edit Default Rules') }
			it { should have_content 'Double Coverage' }
			specify { rule.reload; expect(rule.name).to eq("limit_2") }
		end

	end

end
