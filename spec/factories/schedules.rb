# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    starts_on { 1.month.from_now.to_date.beginning_of_month }
    state 'active'


    penalty_30min 1
    penalty_60min 4
    penalty_90min 16
    penalty_eod_unseen 2
    penalty_slack 2
    penalty_turbo 3
    oren_shift true

  end
end
