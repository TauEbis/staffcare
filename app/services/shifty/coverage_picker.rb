class CoveragePicker

	def initialize(grader)
		@grader = grader
	end

	def pick_best(coverage_options, daily_visits_projection)
		@grader.visits = daily_visits_projection

		best_coverage = coverage_options.first
		min_penalty = penalty(best_coverage)

		coverage_options.each do |coverage|
			pen = penalty(coverage)
			if (pen < min_penalty)
				best_coverage = coverage
				min_penalty = pen
			end
		end

		@grader.visits = nil
		best_coverage
	end


	private

		def penalty(coverage)
			@grader.penalty_with_set_visits(coverage)
		end

		def check_visits_length_and_coverage_span_agree # TODO
			# raise StandardError if daily_visits_projection.size != 2 * ( coverage_options.first[-1]-coverage_options.first[0] )
		end

end