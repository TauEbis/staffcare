FactoryGirl.define do
  factory :grade do
    location
    schedule
    location_plan { create(:location_plan, location: location, schedule: schedule) }

    optimizer_state     :complete

    source 0

    visit_projection    { create(:visit_projection, location: location, schedule: schedule) }
    visits              { visit_projection.visits }
    rooms               5
    max_mds             3
    min_openers         1
    min_closers         1
    open_times          { [8, 8, 8, 8, 8, 8, 8] }
    close_times         { [22, 22, 22, 22, 22, 22, 22] }
    normal              { [0, 4, 8, 12, 16, 24] }
    max                 { [0, 6, 12, 18, 24, 30] }

    coverages { Hash[(schedule.starts_on..schedule.ends_on).map { |day| [day.to_s, Array.new(28, 2)] }] }

    points do
      Hash[(schedule.starts_on..schedule.ends_on).map do |day|
        [day.to_s, {"total"=>39.15, "md_sat"=>9.93, "patient_sat"=>0.0, "cost"=>29.22, "hours"=>41}]
      end ]
    end

    breakdowns do
    	Hash[(schedule.starts_on..schedule.ends_on).map do |day|
    		[day.to_s, { queue: Array.new(28, 2), seen: Array.new(28, 2), turbo: Array.new(28, 2), slack: Array.new(28, 2),
      								penalties: Array.new(28, 2), penalty: 100 }]
    	end ]
    end

    # grade_with_children creates all dependent associated models
    factory :grade_with_children do

      ignore do # replaced by "transient" attributes in edge FactoryGirl
        shift_count 3
      end

      after(:create) do |grade, evaluator|
        create_list(:shift, evaluator.shift_count, grade: grade)
      end

    end

  end
end
