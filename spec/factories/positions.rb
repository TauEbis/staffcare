# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :position do
    key 										:md
    name 										{ "Position #{key}" }
    hourly_rate 						150
    initialize_with { Position.find_or_create_by(key: key) }
  end
end