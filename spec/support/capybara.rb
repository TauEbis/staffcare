require 'capybara'
require 'capybara/dsl'

Capybara.tap do |c|
# c.run_server        = false
# c.default_selector  = :css
# c.default_driver    = :selenium
# c.javascript_driver = :selenium, :webkit
  c.asset_host        = 'http://localhost:3000'
# c.app_host          = 'http://localhost:3000'
end

# ENV['ff'] = './Firefox.app/Contents/MacOS/firefox-bin'

Selenium::WebDriver::Firefox::Binary.path = ENV['ff'] if ENV['ff']

module CapybaraHelpers
  include Capybara::DSL

  def signin(user, options={})
    if options[:no_capybara]
      # Sign in when not using capybara dsl
      Warden.test_reset!
      login_as(user, scope: :user)
    end

    visit new_user_session_path unless options[:already_on_signin_page]
    fill_in 'Email',            with: 'admin@admin.com'#user.email.upcase
    fill_in 'Password',         with: 'password' #user.password
    click_button 'Sign in'      unless options[:no_submit]
  end

  def new_schedule(date)
    click_link 'Schedules'
    click_link 'New Schedule'
    find_field('Starts on').click
#   fill_in 'Starts on', with: '2015-05-01' # 2 months from now
    # ^^^^ Me thinks this is a Gecko bug. Must select calendar date.
    within '.datepicker' do
      # what happens if year is crossed?
      # Must select next year as well
      find('span', text: 'Apr').click
    end
    click_button 'Create Schedule'

    click_link 'Request approvals'
    click_button 'Update Schedule'

    sleep 30
    visit current_path
  end

  def scroll_to(id)
    page.execute_script %Q{document.getElementById('#{id}').scrollIntoView();}
  end
end

RSpec.configure do |config|
  # This is unnecessarily being included for every example group.
  # Only request examples need capybara. No convention in RSpec for spec/features/
# config.include CapybaraHelpers # , type: :request # No bueno for spec/features dir
end
