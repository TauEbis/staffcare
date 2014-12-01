require 'spec_helper'

describe CoveragePicker, :type => :service do

	let (:grader) { CoverageGrader.new( penalty_slack: 180, penalty_30min: 10,
																			penalty_60min: 100, penalty_90min: 300, penalty_eod_unseen: 40, penalty_turbo: 60,
																			normal: [0, 4, 8, 12, 16, 20], max: [0, 6, 12, 18, 24, 30]) }
	let (:picker)		{ CoveragePicker.new(grader) }

	describe "#pick_best" do
		let (:visits ) 	{ Array.new(28,2) }

		it "shoud pick the single coverage for 4 visits per hour" do
			solution_set = [ Array.new(28,2), Array.new(28,1), Array.new(28,3) ]

			exp_coverage = Array.new(28,1)
			exp_breakdown = 	    {
	      queue: Array.new(29,0),
	      seen: Array.new(28,2),
	      turbo: Array.new(28,0),
	      slack: Array.new(28,0),
	      penalties: Array.new(29,0),
	      penalty: 0
	    }
	    exp_points =			{
				total: 0,
				md_sat: 0,
				patient_sat: 0,
				cost: 0,
	      hours: 14
			}

			act_coverage, act_breakdown, act_points = picker.pick_best(solution_set, visits)

			expect(act_coverage).to eq(exp_coverage)
			expect(act_breakdown).to eq(exp_breakdown)
			expect(act_points).to eq(exp_points)
		end
	end
end
