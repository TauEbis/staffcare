FactoryGirl.define do
  factory :grade do
    location_plan
    source 0
    coverages { Hash[(location_plan.schedule.starts_on..location_plan.schedule.ends_on).map { |day| [day.to_s, Array.new(28, 2)] }] }

    breakdowns do
    	Hash[(location_plan.schedule.starts_on..location_plan.schedule.ends_on).map do |day|
    		[day.to_s, { queue: Array.new(28, 2), seen: Array.new(28, 2), turbo: Array.new(28, 2), slack: Array.new(28, 2),
      								penalties: Array.new(28, 2), penalty: 100 }]
    	end ]
    end

  end
end
