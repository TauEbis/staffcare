FactoryGirl.define do
  factory :location_plan do
    location
    schedule

    # assigns a chosen grade (and creates one if necessary)
    after(:create) do |location_plan, evaluator|
      g = location_plan.reload.grades(true).first || create(:grade,
                                                     location_plan: location_plan,
                                                     location: location_plan.location,
                                                     schedule: location_plan.schedule)

      location_plan.update_attribute(:chosen_grade_id, g.id )
    end

    # location_plan_with_children creates all dependent associated models
    factory :location_plan_with_children do

      ignore do # replaced by "transient" attributes in edge FactoryGirl
        push_count  3
        grade_count 3
      end

      after(:create) do |location_plan, evaluator|
        create_list(:grade_with_children, evaluator.grade_count,
                    location:  location_plan.location,
                    schedule: location_plan.schedule,
                    location_plan: location_plan)
        create_list(:push, evaluator.push_count, location_plan: location_plan)
        create(:heatmap, location: location_plan.location )
      end

    end

  end
end
