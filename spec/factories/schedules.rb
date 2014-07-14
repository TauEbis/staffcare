# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    starts_on { 1.weeks.from_now.to_date }
    state 'active'


    penalty_30min 1
    penalty_60min 4
    penalty_90min 16
    penalty_eod_unseen 2
    penalty_slack 2.5
    md_rate 4.25
    oren_shift true

  end
end
