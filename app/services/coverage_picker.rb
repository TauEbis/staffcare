class CoveragePicker

	def initialize(grader)
		@grader = grader
	end

	def pick_best(solution_set, daily_visits_projection)
		@grader.visits = daily_visits_projection

		best_coverage = solution_set.first
		min_penalty = penalty(best_coverage)

		solution_set.each do |coverage|
			pen = penalty(coverage)
			if (pen < min_penalty)
				best_coverage = coverage
				min_penalty = pen
			end
		end

		@grader.visits = nil

		return best_coverage, min_penalty
	end


	private

		def penalty(coverage)
			@grader.penalty_with_set_visits(coverage)
		end

		def check_visits_length_and_coverage_span_agree # TODO
			# raise StandardError if daily_visits_projection.size != 2 * ( solution_set.first[-1]-solution_set.first[0] )
		end

end
