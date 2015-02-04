require 'spec_helper'

describe VisitBuilder, :type => :service do
	let (:visit_builder) { VisitBuilder.new() }
	let (:location1) { FactoryGirl.create(:location) }
	let (:location2) { FactoryGirl.create(:location) }
	let (:schedule ) { FactoryGirl.create(:schedule) }
  let! (:volume_projection) { FactoryGirl.create(:patient_volume_forecast) }

	subject { visit_builder }

		it { should respond_to(:build_projection!) }
    pending "#build_projection!"
    pending "sanity test private methods: #volume_query, #heatmap_query, #build_visits"
end
