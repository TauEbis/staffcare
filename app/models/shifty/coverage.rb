class Coverage

	attr_accessor :grader_weights
	attr_reader :locations, :time_period, :visits, :optimized_graded_coverage, :manual_graded_coverage

	def initialize(opts={})

		@locations = opts[:locations] || dummy_locations # Could also be Location.where(active: true)
		@time_period = opts[:time_period] || dummy_time_period
		@visits = opts[:visits] || Visits.new.build_for(@locations, @time_period)
		@grader_weights = opts[:grader_weights] || dummy_grader_weights

		@optimized_graded_coverage = GradedCoverage.new(self)
		@optimized_graded_coverage.optimize_coverage
		@manual_graded_coverage = GradedCoverage.new(self)

	end

	def optimize
		@optimized_graded_coverage.optimize_coverage
	end

	def reoptimize(grader_weights = dummy_grader_weights)
		@grader_weights=grader_weights
		@optimized_graded_coverage = GradedCoverage.new(self)
		optimize
	end

	def reload_visits(opts={})
		@locations = opts[:locations] || dummy_locations # Could also be Location.where(active: true)
		@time_period = opts[:time_period] || dummy_time_period
		@visits = opts[:visits] || Visits.new.build_for(@locations, @time_period)
	end

	private

		def dummy_locations
			[ Location.new(name: "Park Slope", max_mds: 3, rooms: 12, open: Array.new(7, 8), close: Array.new(7, 22)) ]
		end

		def dummy_time_period
			TimePeriod.new(Date.today, Date.today + 0)
		end

		def dummy_grader_weights
			{ md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4 }
		end
end

# Note: With active record will associate to location etc.
# TODO: Add day of week vailidation for TimePeriods since they always begin on Sundays and end on Saturday 4 weeks later.
# TODO: Vailidate visits match locations open and close