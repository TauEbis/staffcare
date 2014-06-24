class GradedCoveragePlan

	attr_reader :schedule, :locations, :visits_projection, :grader_weights, :coverages, :penalties, :grades, :location_grades, :coverage_plan_grades

	def initialize(coverage_plan)

# TODO: Add methods to display actual selected shifts from coverage, equivalent shifts, and to reference the queue model
# TODO: Should store coverage opts_key (open, close, max_mds, min_openers, min_closers) value for each location, day

		@locations = coverage_plan.locations
		@schedule = coverage_plan.schedule
		@visits_projection = coverage_plan.visits_projection
		@grader_weights = coverage_plan.grader_weights

		@coverages = Hash.new{ |hash, key| hash[key] = Hash.new(Array.new) }
		@penalties = Hash.new{ |hash, key| hash[key] = Hash.new }

		@grades = Hash.new{ |hash, key| hash[key] = Hash.new(Array.new(4, 0)) } # Daily (coverage) grades for pat_sat, md_sat, cost, & overall
		@location_grades = Hash.new(Array.new(4, 0)) # Location (Monthly) grades for pat_sat, md_sat, cost, & overall
		@coverage_plan_grades = Array.new(4, 0) # Coverage (Monthly) grades for pat_sat, md_sat, cost, & overall
	end

end
