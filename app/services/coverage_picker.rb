class CoveragePicker

	def initialize(grader)
		@grader = grader
	end

	def pick_best(solution_set, daily_visits_projection)

		@grader.set_visits = daily_visits_projection

		best_coverage = solution_set.first
		min_penalty = penalty(best_coverage)

		solution_set.each do |coverage|
			pen = penalty(coverage)
			if (pen < min_penalty)
				best_coverage = coverage
				min_penalty = pen
			end
		end

		return best_coverage, min_penalty.round(2)
	end


	private

		def penalty(coverage)
			@grader.penalty_with_set_visits(coverage)
		end

		def check_visits_length_and_coverage_span_agree # TODO
			# raise StandardError if daily_visits_projection.size != solution_set.first.size )
		end

end
