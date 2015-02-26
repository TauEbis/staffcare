include ApplicationHelper

def signin(user, options={})
  if options[:no_capybara]
    # Sign in when not using capybara dsl
    login_as(user, :scope => :user)
  else
    visit new_user_session_path unless options[:already_on_signin_page]
    fill_in "Email", with: user.email.upcase
    fill_in "Password", with: user.password
    click_button "Sign in" unless options[:no_submit]
  end
end

def new_patient_volume_forecast(forecast, locations, options={})
	fill_in_forecast_info(forecast, locations)
	click_button "Create Patient volume forecast" if options[:submit]
end

def edit_patient_volume_forecast(forecast, locations, options={})
	fill_in_forecast_info(forecast, locations)
	click_button "Update Patient volume forecast" if options[:submit]
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

	def fill_in_forecast_info(forecast, locations)
			fill_in "Start date", 						with: forecast.start_date
			fill_in "End date", 							with: forecast.end_date
		locations.each do |l|
			fill_in l.name.to_s,			 							with: forecast.volume_by_location[l.upload_id]
		end
	end

