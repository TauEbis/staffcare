class GradedCoverage

	attr_reader :time_period, :locations, :visits, :grader_weights
	attr_accessor :shift_sets, :penalties

	def initialize(coverage)

# TODO: Clone these in some reasonable way so even if coverage, locations etc. is updated, the GradedCoverage is not
		@locations = coverage.locations
		@time_period = coverage.time_period
		@visits = coverage.visits
		@grader_weights = coverage.grader_weights

		@shift_sets = Hash.new{ |hash, key| hash[key] = Hash.new(Array.new) }
		@penalties = Hash.new{ |hash, key| hash[key] = Hash.new }

		@location_daily_grades = Hash.new{ |hash, key| hash[key] = Hash.new(Array.new(4, 0)) } # Daily (shift_set) grades for pat_sat, md_sat, cost, & overall
		@location_grades = Hash.new(Array.new(4, 0)) # Location (Monthly) grades for pat_sat, md_sat, cost, & overall
		@coverage_grades = Array.new(4, 0) # Coverage (Monthly) grades for pat_sat, md_sat, cost, & overall
	end

	def optimize_coverage
		CoverageOptimizer.new.optimize( @locations, @time_period, @visits, @grader_weights, self )
	end

	def grade_location_day(location, day)
		grader = Grader.new(@grader_weights)
		shift_set = @shift_sets[location.to_sym][day.to_s]
		day_visits = @visits.half_hr_visits[location.to_sym][day.to_s]
		grader.penalty(shift_set, day_visits)
	end

	def grade_location(location)
		result = Hash.new()
		@time_period.days.each do |day|
			result[day.to_s] = grade_location_day(location, day)
		end
		result
	end

	def grade_coverage
		result = Hash.new # TODO make the result meaningful
		@locations.each do |location|
			result[location.to_sym] = grade_location(location)
		end
		result # TODO make the result meaningful. Probably Analytics instead of penalty hash
	end

end

# TODO: Add methods to display actual selected shifts from shift_set, equivalent shifts, and to reference the queue model