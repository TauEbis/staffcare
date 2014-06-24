class CoveragePlansController

	def initialize(opts={})
		@data_source = opts[:data_source] || get_data_source
		@data_provider = DataProvider.new(@data_source)
	end

	def create(opts={})
		@locations = opts[:locations] || get_current_locations
		@schedule = opts[:schedule] || get_schedule
		grader_weights = opts[:grader_weights] || get_grader_weights
		@grader = CoverageGrader.new(grader_weights)
		@visits_projection = opts[:visits_projection] || build_visits_projection

		@coverage_plan = CoveragePlan.new(locations: @locations, schedule: @schedule, grader: @grader, visits_projection: @visits_projection)
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
			@schedule = opts[:schedule] || dummy_schedule
			@visits_projection = opts[:visits_projection] || build_visits_projection
		end

		def get_data_source
			dummy_data_source
		end

		def get_current_locations
			dummy_locations # Could also be Location.where(active: true)
		end

		def get_schedule
			dummy_schedule
		end

		def get_grader_weights
			dummy_grader_weights
		end

		def build_visits_projection
			VisitProjection.import!(@data_provider, @schedule)
		end

		def dummy_data_source
			:dummy
		end

		def dummy_locations
			[ Location.new(name: "Park Slope", report_server_id: "ParkSlope", max_mds: 3, rooms: 12, open_times: Array.new(7, 8), close_times: Array.new(7, 22)) ]
		end

		def dummy_schedule
			Schedule.new(starts_on: Date.today)
		end

		def dummy_grader_weights
			{ md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4 }
		end

		def dummy_coverage_plan
			@locations = dummy_locations
			@schedule = dummy_schedule
			@grader = CoverageGrader.new(dummy_grader_weights)
			@visits_projection = build_visits_projection
			CoveragePlan.new(locations: @locations, schedule: @schedule, grader: @grader, visits_projection: @visits_projection)
		end
end
