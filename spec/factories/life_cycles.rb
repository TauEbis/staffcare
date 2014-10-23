# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :life_cycle do
    name "MyString"
    min_daily_volume 1
    max_daily_volume 1
    scribe_policy 1
    pcr_policy 1
    ma_policy 1
    xray_policy 1
    am_policy 1
    default false
  end
end
