FactoryGirl.define do
  factory :visit_projection do
    location
    schedule
    source 'dummy'
    visits { Hash[(schedule.starts_on..schedule.ends_on).map { |day| [day.to_s, Array.new(28, 4)] }] }
    volumes { Hash[(schedule.starts_on..schedule.ends_on).map { |day| [day.to_s, 4] }] }
    #t.json     "heat_maps"
    #t.json     "volumes"
    #t.json     "visits"
  end
end
