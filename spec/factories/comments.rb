# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    user
    location_plan
    cause 1
    body "MyText"
  end
end
