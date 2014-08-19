FactoryGirl.define do
  factory :location_plan do
    location
    schedule
    visit_projection { create(:visit_projection, location: location) }
    visits { visit_projection.visits }
    rooms 5
    max_mds 3
    min_openers 1
    min_closers 1
    open_times [9,8,8,8,8,8,9]
    close_times [22,21,21,21,21,21,22]
    normal [0, 4, 4, 4, 4, 4]
    max [0, 6, 6, 6, 6, 6]
    after(:create) do |location_plan, evaluator|
      g = location_plan.grades(true).first || create(:grade, location_plan: location_plan)
      location_plan.update_attribute(:chosen_grade_id, g.id )
    end
  end
end
