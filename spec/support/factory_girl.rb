RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    #FactoryGirl.lint
  end
end

FactoryGirl.define do
  #sequence :email do |n|
  #  "person#{n}@example.com"
  #end
end
