source 'https://rubygems.org'

ruby '2.1.2'
#ruby=2.1.2
#ruby-gemset=staffcare

gem 'rails', '4.1.1'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jquery-turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
#gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
#gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'bootstrap-sass'
gem 'devise'
gem 'devise_invitable'
#gem 'devise_zxcvbn'
gem 'pg'
gem 'pundit'

gem 'simple_form', '>= 3.1.0.rc1'
gem 'bootstrap-datepicker-rails'

gem 'newrelic_rpm'
gem 'rollbar'

group :staging, :production do
  gem 'rails_12factor'
  gem 'unicorn'
  gem 'unicorn-rails'
end

group :development do
  gem 'spring'
  gem "letter_opener"
  gem 'better_errors'
  gem 'binding_of_caller', :platforms=>[:mri_21]
  gem 'foreman'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'quiet_assets'
  gem 'rails_layout'
  gem 'rb-fchange', :require=>false
  gem 'rb-fsevent', :require=>false
  gem 'rb-inotify', :require=>false
end

group :development, :test do
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'rspec-rails', '>= 3.0.0.beta2'
  gem 'spring-commands-rspec'
end

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'faker'
  gem 'launchy'
  gem 'selenium-webdriver'
end
