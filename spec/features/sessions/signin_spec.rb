require 'spec_helper'

# Feature: Sign in
#   As a visitor
#   I want to be able to sign in to my account
#   So I can find home, sign in, or sign up
feature 'Sign in', :devise do

  # Scenario: Successful sign in
  #   Given I am a visitor
  #   And I have an existing account
  #   When I visit the sign in page
  #   And enter my credentials
  #   Then I am successfully signed in
  scenario 'successful sign in' do
    user = create(:admin_user)
    expect(User.count).to eq(1)

    visit root_path
    expect(page).to have_link('Sign in', href: new_user_session_path)

    signin user
    expect(page).to have_content 'Signed in successfully'
  end

end
