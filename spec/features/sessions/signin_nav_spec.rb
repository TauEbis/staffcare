require 'spec_helper'

feature 'Signed-in navigation bar: ', :devise do
  subject { page }

  describe "Given a signed-in non-admin user visits the site," do
    given(:user) { FactoryGirl.create(:user) }
    background do
      signin user
    end

    describe 'then they will see the signed-in non-admin nav bar' do
      it { should have_link('Home', href: root_path ) }
      it { should have_link('edit profile', href: profile_user_path(user) ) }
      it { should have_link('Sign out', href: destroy_user_session_path ) }

      it { should_not have_link('Locations', href: locations_path) }
      it { should_not have_link('Zones', href: zones_path) }
      it { should_not have_link('Users', href: users_path) }
      it { should_not have_link('Staffing Analyst', href: staffing_analyst_path) }

      it { should_not have_link('Sign in', href: new_user_session_path) }

    end
  end

  describe "Given an admin visits the site," do
    given(:admin) { FactoryGirl.create(:admin_user) }
    background do
      signin admin
    end

    describe 'then they will see the admin nav bar' do
      it { should have_link('Home', href: root_path ) }
      it { should have_link('Schedules', href: schedules_path ) }
      it { should have_link('edit profile', href: profile_user_path(admin) ) }
      it { should have_link('Sign out', href: destroy_user_session_path ) }

      it { should have_link('Locations', href: locations_path) }
      it { should have_link('Zones', href: zones_path) }
      it { should have_link('Users', href: users_path) }
      it { should have_link('Staffing Analyst', href: staffing_analyst_path) }

      it { should_not have_link('Sign in', href: new_user_session_path) }
    end
  end

end
