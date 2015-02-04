FactoryGirl.define do
  factory :visit_projection do
    location
    schedule
    volume_source :patient_volume_forecasts
    visits { Hash[(schedule.starts_on..schedule.ends_on).map { |day| [day.to_s, Array.new(28, 4)] }] }
    volumes { Hash[(schedule.starts_on..schedule.ends_on).map { |day| [day.to_s, 4] }] }
  end
end
