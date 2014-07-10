# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :input_projection do
  	ignore do
  		locations { [ create(:location), create(:location)] }
  	end

    sequence(:start_date) { |n| Date.today + n }
    end_date { start_date + 27 }

    sequence(:volume_by_location) do |n|
			acc=Hash.new
			locations.each do |location|
				acc[location.id.to_s] = 800 + 3*n + 40*location.id - 15
			end
			acc
		end

  end
end