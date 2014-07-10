# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :zone do
    sequence(:name) 				{ |n| "Zone #{n}" }
  end
end
