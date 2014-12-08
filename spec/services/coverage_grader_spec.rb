require 'spec_helper'

describe CoverageGrader, :type => :service do
	let (:grader) { CoverageGrader.new( penalty_slack: 180, penalty_30min: 10,
																			penalty_60min: 100, penalty_90min: 300, penalty_eod_unseen: 40, penalty_turbo: 60,
																			normal: [0, 4, 8, 12, 16, 20], max: [0, 6, 12, 18, 24, 30]) }

	describe "#penalty" do
		describe "sanity check" do

			describe "single coverage" do
				let (:coverage) { Array.new(28,1) }

				it "can see 2 patients per half hour with no penalty" do
					visits = Array.new(28,2)
					expect( grader.penalty(coverage, visits) ).to eq(0)
				end
			end

			describe "double coverage" do
				let (:coverage) { Array.new(28,2) }

				it "can see 4 patients per half hour with no penalty" do
					visits = Array.new(28,4)
					expect( grader.penalty(coverage, visits) ).to eq(0)
				end
			end

		end

		describe "error handling" do
			let (:coverage) { Array.new(29,2) }

			it "throws an error if visits and coverage have different lengths" do
				visits = Array.new(28,4)
				expect{grader.penalty(coverage, visits) }.to raise_error(ArgumentError, "timeslots for visits and coverage must be equal")
			end
		end

		describe "running without visits a second time" do
			let (:coverage) { Array.new(28,2) }

			it "should return the same result" do
				visits = Array.new(28,4)
				expected = grader.penalty(coverage, visits)
				expect( grader.penalty(coverage) ).to eq(expected)
			end
		end

		describe "running with coverage greater than top speed" do
			let (:coverage) { Array.new(28,2) } # double coverage

			it "should return the same result" do
				visits = Array.new(28,4) # 8 pph

				grader.instance_variable_set(:@normal_speeds, [0, 4])
				grader.instance_variable_set(:@max_speeds, [0, 6])

				act_breakdown, act_points = grader.full_grade(coverage, visits)

				expect( act_breakdown[:seen] ).to eq(Array.new(28,3)) # 6 pph -- 1 md turboing
				expect( act_points[:hours] ).to eq(28) # double coverage
				expect( grader.instance_variable_get(:@penalty_slack_vector) ).to eq(Array.new(28, 45)) # slack penalty for 1 md coverage
				expect( act_breakdown[:slack] ).to eq(Array.new(28, 0)) # no slack in system for 1 md
				expect( act_points[:cost] ).to eq(180*14) # cost of the completely unused md
			end
		end

	end

	describe "#full_grade" do
		describe "breakdown" do
			let (:coverage) { Array.new(28,1) }

			it "single coverage with full turbo and always 1 visitor in queue" do
				visits = [4] + Array.new(27,3)
				act_breakdown, act_points = grader.full_grade(coverage, visits)

				expect( act_breakdown[:queue] ).to eq( [0] + Array.new(28, 1) )
				expect( act_breakdown[:seen] ).to eq( Array.new(28, 3) )
				expect( act_breakdown[:turbo] ).to eq( Array.new(28, 1) )
				expect( act_breakdown[:slack] ).to eq( Array.new(28, 0) )
				expect( act_breakdown[:penalties] ).to eq( [60] + Array.new(27, 70) + [40] )
				expect( act_breakdown[:penalty] ).to eq( 60 + 27 * 70 + 40 )
			end

			it "single coverage with 3 visitors has constant slack and no turbo or queue" do
				visits = Array.new(28,1.5)
				act_breakdown, act_points = grader.full_grade(coverage, visits)

				expect( act_breakdown[:queue] ).to eq( Array.new(29, 0) )
				expect( act_breakdown[:seen] ).to eq( Array.new(28, 1.5) )
				expect( act_breakdown[:turbo] ).to eq( Array.new(28, 0) )
				expect( act_breakdown[:slack] ).to eq( Array.new(28, 0.5) )
				expect( act_breakdown[:penalties] ).to eq( Array.new(28, 180/4.0/2) + [0] )
				expect( act_breakdown[:penalty] ).to eq( 28 * 180/8.0 )
			end
		end

		describe "points" do
			let (:coverage) { Array.new(28,1) }

			it "single coverage with full turbo and always 1 visitor in queue" do
				visits = [4] + Array.new(27,3)
				act_breakdown, act_points = grader.full_grade(coverage, visits)

				expect( act_points[:md_sat] ).to eq( 28*60*1 + 1*40 )
				expect( act_points[:patient_sat] ).to eq( 27*10 )
				expect( act_points[:cost] ).to eq( 0*180 )
				expect( act_points[:total] ).to eq( 28*60*1 + 1*40 + 27*10 + 0*180 )
				expect( act_points[:hours] ).to eq( 28*0.5 )
			end

			it "single coverage with 3 visitors has constant slack and no turbo or queue" do
				visits = Array.new(28,1.5)
				act_breakdown, act_points = grader.full_grade(coverage, visits)

				expect( act_points[:md_sat] ).to eq( 28*0 + 0*40 )
				expect( act_points[:patient_sat] ).to eq( 27*0 )
				expect( act_points[:cost] ).to eq( 28*180/4*0.5 )
				expect( act_points[:total] ).to eq( 28*0 + 0*40 + 27*0 + 28*180/4*0.5 )
				expect( act_points[:hours] ).to eq( 28*0.5 )
			end
		end

		context "when coverage is zero" do
			let (:coverage) { Array.new(28,0) }
			it "should not return NaN errors" do
				visits = Array.new(28,2)
				act_breakdown, act_points = grader.full_grade(coverage, visits)
				expect( act_points[:cost].nan? ).to be(false)
				expect( act_points[:total].nan? ).to be(false)
			end
		end

	end

end
