# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :position do
    sequence(:name) 				{ |n| "Position #{n}" }
    hourly_rate 						150
    key 										:md
  end
end