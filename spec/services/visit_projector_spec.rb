require 'spec_helper'

describe VisitProjector, :type => :service do
	let (:visit_projector) { VisitProjector.new() }
	let (:location1) { FactoryGirl.create(:location) }
	let (:location2) { FactoryGirl.create(:location) }
	let (:schedule ) { FactoryGirl.create(:schedule) }
  let (:volume_projection) { FactoryGirl.create(:patient_volume_projection) }

	subject { visit_projector }

		it { should respond_to(:project!) }
    pending "#project!"
    pending "sanity test private methods: #volume_query, #heatmap_query, #build_visits"
end
