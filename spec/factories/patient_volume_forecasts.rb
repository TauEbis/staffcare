# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :patient_volume_forecast do
  	ignore do
  		locations { [ create(:location), create(:location)] }
  	end

    sequence(:start_date) { |n| Date.parse('2014-07-04') + (7 * n) }
    end_date { start_date + 6 }

    sequence(:volume_by_location) do |n|
			acc=Hash.new
			locations.each do |location|
				acc[location.report_server_id.to_s] = 800 + 3*n + 40*location.id - 15 # generate randomish volume data using the id
			end
			acc
		end

  end
end
