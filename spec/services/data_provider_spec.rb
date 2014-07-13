require 'spec_helper'

describe DataProvider, :type => :service do
	let (:data_provider) { DataProvider.new("database") }
	let (:location1) { FactoryGirl.create(:location) }
	let (:location2) { FactoryGirl.create(:location) }
	let (:schedule ) { FactoryGirl.create(:schedule) }
  let (:volume_projection) { FactoryGirl.create(:patient_volume_projection) }

	subject { data_provider }

		it { should respond_to(:heat_map_query) }
		it { should respond_to(:volume_query) }

end
