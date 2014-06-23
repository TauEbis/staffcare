class CoveragePlanOptimizer

	def optimize(locations, time_period, visits_projection, grader, graded_coverage_plan)

		loader = SpeedyCoverageOptionsLoader.new
		picker = CoveragePicker.new(grader)

		locations.each do |location|
			time_period.days.each do |day|

				day_visits = visits_projection.visits[location.to_sym][day.to_s]
				coverage_options = loader.load(location, day)

				best_coverage = picker.pick_best(coverage_options, day_visits)
				graded_coverage_plan.coverages[location.to_sym][day.to_s] = best_coverage
				graded_coverage_plan.penalties[location.to_sym][day.to_s] = grader.penalty(best_coverage, day_visits)

			end
		end

	end
end