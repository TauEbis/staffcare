require 'spec_helper'

describe CoverageGrader, :type => :service do
	let (:grader) { CoverageGrader.new(md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4) }
	let (:coverage) { ( Array.new(4,2) + Array.new(20,3) + Array.new(4, 2) ) }
	let (:visits ) { [3.08, 4.54, 4.97, 3.17, 3.85, 2.74, 3.60, 3.85, 3.08, 3.34, 3.51, 3.60, 3.17, 3.60, 3.68, 2.57, 3.00, 3.08, 4.63, 3.51, 4.37, 4.28, 3.25, 2.48, 2.48, 2.14, 1.45, 0.77] }
	let (:penalty) { grader.penalty(coverage, visits) }

	subject { grader }

		it { should respond_to(:penalty) }
		it { should respond_to(:set_visits=) }
		it { should respond_to(:penalty_with_set_visits) }

		describe "#set_visits" do

			before { grader.set_visits=visits }

			context "when penalty_with_set_vistis is called it should equal the penalty" do
				let (:penalty_set_visits) { grader.penalty_with_set_visits(coverage) }
				specify { expect(penalty_set_visits).to eq(penalty) }
			end

		end

end
