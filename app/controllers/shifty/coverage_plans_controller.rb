class CoveragePlansController

	def initialize(opts={})
		@data_source = opts[:data_source] || get_data_source
		@data_provider = DataProvider.new(@data_source)
	end

	def create(opts={})
		@locations = opts[:locations] || get_current_locations
		@time_period = opts[:time_period] || get_time_period
		grader_weights = opts[:grader_weights] || get_grader_weights
		@grader = CoverageGrader.new(grader_weights)
		@visits_projection = opts[:visits_projection] || build_visits_projection

		@coverage_plan = CoveragePlan.new(locations: @locations, time_period: @time_period, grader: @grader, visits_projection: @visits_projection)
		@coverage_plan.optimize
		@coverage_plan.set_chosen_plan_to_optimize
		@coverage_plan
	end

	def update(opts={})
		@coverage_plan = opts[:coverage_plan] || dummy_coverage_plan
		grader_weights = opts[:grader_weights] || dummy_grader_weights
		@grader = CoverageGrader.new(grader_weights)
		reload_visits_projection if opts[:reload] # this will likely change to an ajax call
		@coverage_plan.reoptimize(@grader, @visits_projection)
		@coverage_plan
	end

	private

		def reload_visits_projection(opts={})
			@data_source = opts[:data_source] || get_data_source
			@data_provider = DataProvider.new(@data_source)
			@locations = opts[:locations] || dummy_locations
			@time_period = opts[:time_period] || dummy_time_period
			@visits_projection = opts[:visits_projection] || build_visits_projection
		end

		def get_data_source
			dummy_data_source
		end

		def get_current_locations
			dummy_locations # Could also be Location.where(active: true)
		end

		def get_time_period
			dummy_time_period
		end

		def get_grader_weights
			dummy_grader_weights
		end

		def build_visits_projection
			VisitsProjection.new(@data_provider).project_for(@locations, @time_period)
		end

		def dummy_data_source
			:dummy
		end

		def dummy_locations
			[ Location.new(name: "Park Slope", max_mds: 3, rooms: 12, open: Array.new(7, 8), close: Array.new(7, 22)) ]
		end

		def dummy_time_period
			TimePeriod.new(Date.today, Date.today + 0)
		end

		def dummy_grader_weights
			{ md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4 }
		end

		def dummy_coverage_plan
			@locations = dummy_locations
			@time_period = dummy_time_period
			@grader = CoverageGrader.new(dummy_grader_weights)
			@visits_projection = build_visits_projection
			CoveragePlan.new(locations: @locations, time_period: @time_period, grader: @grader, visits_projection: @visits_projection)
		end
end