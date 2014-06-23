class CoveragePlan

	attr_reader :locations, :time_period, :grader_weights, :visits_projection, :chosen_coverage_plan, :optimized_graded_coverage_plan, :manual_graded_coverage_plan

	def initialize(opts={})

# TODO: Clone locations/time_period data in some reasonable way so even if it is updated, the CoveragePlan doesn't break. Does this data reload wth the visits data?
# TODO Should store coverage opts_key value for each location, day including open and close
# TODO: Add day of week validation for TimePeriods since they always begin on Sundays and end on Saturday 4 weeks later.
# TODO: Vailidate visits match locations open and close

# Can not be changed after initialize
		@locations = opts[:locations]
		@time_period = opts[:time_period]

# Can be changed after initialize
		@grader = opts[:grader]
		@grader_weights = @grader.weights
		@visits_projection = opts[:visits_projection]

# Master CoveragePlan that the user selects per location
		@chosen_coverage_plan = GradedCoveragePlan.new(self)

# CoveragePlans to mix and match from:
		@optimized_graded_coverage_plan = GradedCoveragePlan.new(self) #locked
		@manual_graded_coverage_plan = GradedCoveragePlan.new(self) #editable
		@last_months_coverage_plan = GradedCoveragePlan.new(self) #locked

	end

	def optimize
		CoveragePlanOptimizer.new.optimize( @locations, @time_period, @visits_projection, @grader, @optimized_graded_coverage_plan )
	end

	def reoptimize(grader, visits_projection)
		@grader = grader
		@grader_weights = @grader.weights
		@visits_projection = visits_projection

		@optimized_graded_coverage_plan = GradedCoveragePlan.new(self)
		optimize
	end

	def set_chosen_plan_to_optimize
		@chosen_coverage_plan = @optimized_graded_coverage_plan
	end

	def grade_chosen_coverage_plan
		@locations.each do |location|
			@chosen_coverage_plan.grades[location.to_sym] = grade_chosen_coverage_plan_location(location)
		end
	end

	private

		def grade_chosen_coverage_plan_location(location)
			result= Hash.new
			@time_period.days.each do |day|
				result[day.to_s] = grade_chosen_coverage_plan_location_day(location, day)
			end
			result
		end

		def grade_chosen_coverage_plan_location_day(location, day)
			coverage = @chosen_coverage_plan.coverages[location.to_sym][day.to_s]
			day_visits = @visits_projection.visits[location.to_sym][day.to_s]
			@grader.penalty(coverage, day_visits)  # TODO make the result meaningful. Probably Analytics instead of penalty hash
		end
end