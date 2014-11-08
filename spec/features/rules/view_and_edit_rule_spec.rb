require 'spec_helper'

feature "Viewing and editing rules: " do

  subject { page }

  describe "Given a non-admin user visits the index page," do
		given(:user) { FactoryGirl.create(:user) }

		background do
			signin user
			visit rules_path
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('All rules') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the index page," do
		given(:admin) { FactoryGirl.create(:admin_user) }

		background do
			Position.create_key_positions
			Rule.create_default_template
			signin admin
			visit rules_path
		end

  	describe "then the index page is rendered:" do

			it { should have_title full_title('All Rules') }
			it { should have_content("Position") }
			it { should have_content("Default Rule") }
			it { should have_content("Single Coverage") }
		end
	end

	describe "Given a non-admin user visits the edit page," do
		given(:user) { FactoryGirl.create(:user) }
		background do
			signin user
			visit edit_rule_path(FactoryGirl.create(:rule))
		end

  	describe "then the index page is not rendered:" do
			it { should_not have_title full_title('Edit Rule') }
			it { should have_title full_title('Dashboard') }
		end
	end

  describe "Given am admin visits the edit page," do
		given(:admin) { FactoryGirl.create(:admin_user) }
		given(:rule) { FactoryGirl.create(:rule, name: "limit_1", position: create(:position, key: :ma), grade: nil) }

		background do
			signin admin
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
			it { should have_title full_title('All Rules') }
			it { should have_content 'Double Coverage' }
			specify { rule.reload; expect(rule.name).to eq("limit_2") }
		end

	end

end
