FactoryGirl.define do
  factory :visit_projection do
    location
    schedule
    source 'dummy'
    #t.json     "heat_maps"
    #t.json     "volumes"
    #t.json     "visits"
  end
end
