include ApplicationHelper
include Warden::Test::Helpers
Warden.test_mode!

def signin(user, options={})
	if options[:no_capybara]
		# Sign in when not using capybara dsl
		Warden.test_reset!
		login_as(user, :scope => :user)
	else
		visit new_user_session_path			unless options[:already_on_signin_page]
		fill_in "Email", 								with: user.email.upcase
		fill_in "Password", 						with: user.password
		click_button "Sign in" 					unless options[:no_submit]
	end
end

def new_input_projection(projection, locations, options={})
	fill_in_projection_info(projection, locations)
	click_button "Create Input projection" if options[:submit]
end

def edit_input_projection(projection, locations, options={})
	fill_in_projection_info(projection, locations)
	click_button "Update Input projection" if options[:submit]
end

RSpec::Matchers.define :have_error_message do | message |
	match do |page|
		page.has_selector?('div.has-error span.help-block', text: message)
	end
end

RSpec::Matchers.define :have_success_message do | message |
	match do |page|
		page.has_selector?('div.alert.alert-success', text: message)
	end
end

	private

	def fill_in_projection_info(projection, locations)
			fill_in "Start date", 						with: projection.start_date
			fill_in "End date", 							with: projection.end_date
		locations.each do |l|
			fill_in l.name.to_s,			 							with: projection.volume_by_location[l.id.to_s]
		end
	end

