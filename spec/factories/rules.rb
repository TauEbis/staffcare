# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :rule do
    name 									:limit_1
		position
    grade
    shift_space_params 		{ { staff_min: 1, staff_max: 3, shift_min: 6, shift_max: 12 } }
		step_params 					{ { steps: [0, 0, 8, 12, -1] } }
  end
end
