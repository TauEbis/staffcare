class CoveragePicker

	def initialize(grader)
		@grader = grader
	end

	def pick_best(solution_set, daily_visits_projection)

		best_coverage = solution_set.first
		min_penalty = @grader.penalty(best_coverage, daily_visits_projection) # visits is now set for all further penalty calls

		solution_set.each do |coverage|
			pen = @grader.penalty(coverage)
			if (pen < min_penalty)
				best_coverage, min_penalty = coverage, pen
			end
		end

		best_breakdown, best_points = @grader.full_grade(best_coverage)

    return best_coverage, best_breakdown, best_points
	end

end
