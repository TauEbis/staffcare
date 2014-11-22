FactoryGirl.define do
  factory :location_plan do
    location
    schedule
    visit_projection    { create(:visit_projection, location: location, schedule: schedule) }
    visits              { visit_projection.visits }
    rooms               5
    max_mds             3
    min_openers         1
    min_closers         1
    open_times          [8,8,8,8,8,8,8]
    close_times         [22,22,22,22,22,22,22]
    normal              [0, 4, 4, 4, 4, 4]
    max                 [0, 6, 6, 6, 6, 6]
    optimizer_state     :complete

    # assigns a chosen grade (and creates one if necessary)
    after(:create) do |location_plan, evaluator|
      g = location_plan.grades(true).first || create(:grade, location_plan: location_plan)
      location_plan.update_attribute(:chosen_grade_id, g.id )
    end

    # location_plan_with_children creates all dependent associated models
    factory :location_plan_with_children do

      ignore do # replaced by "transient" attributes in edge FactoryGirl
        push_count  3
        grade_count 3
      end

      after(:create) do |location_plan, evaluator|
        create_list(:grade_with_children, evaluator.grade_count, location_plan: location_plan)
        create_list(:push, evaluator.push_count, location_plan: location_plan)
        create(:heatmap, location: location_plan.location, uid: location_plan.location.uid )
      end

    end

  end
end
