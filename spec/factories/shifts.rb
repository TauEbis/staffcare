# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :shift do
    grade
    association :position, strategy: :build
    starts_at 1.hour.from_now.beginning_of_hour
    ends_at { starts_at + 8.hours }
  end
end
