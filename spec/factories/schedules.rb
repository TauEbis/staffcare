# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :schedule do
    starts_on               { 1.month.from_now.to_date.beginning_of_month }
    state                   'active'

    penalty_30min           10
    penalty_60min           100
    penalty_90min           300
    penalty_eod_unseen      40
    penalty_slack           60
    penalty_turbo           180

    optimizer_state         :complete

    # schedule_with_children creates all dependent associated models
    factory :schedule_with_children do

      ignore do # replaced by "transient" attributes in edge FactoryGirl
        location_plan_count 3
      end

      after(:create) do |schedule, evaluator|
        create_list(:location_plan_with_children, evaluator.location_plan_count, schedule: schedule)
        create(:patient_volume_forecast, start_date: schedule.starts_on.beginning_of_week + 4.days)
      end

    end

  end
end
