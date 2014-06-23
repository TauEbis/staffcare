#!/usr/bin/env ruby

require './bin/shifty_file_loader.rb'

# Sample CityMD Data
	locations = [
		Location.new(name: "CityMD_14th_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	  Location.new(name: "CityMD_23rd_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	  Location.new(name: "CityMD_57th_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	  Location.new(name: "CityMD_67th_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	  Location.new(name: "CityMD_86th_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	  Location.new(name: "CityMD_88th_St", max_mds: 3, rooms: 12, open: [9,8,8,8,8,8,9], close: [21,22,22,22,22,22,21]),
	]

	time_period = TimePeriod.new("2014-06-06", "2014-07-03")

	grader_weights = { md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4 }

# Set contoller to use sample run CityMD visits data
	controller = CoveragePlansController.new(data_source: :sample_run)

# Create coverage plan with default data inputs. This will also create an optimized coverage option
	coverage_plan = controller.create(locations: locations, time_period: time_period, grader_weights: grader_weights)

# Print result of optimization to console
	optimized_coverage_plan = coverage_plan.optimized_graded_coverage_plan
	puts optimized_coverage_plan.coverages.inspect
	puts optimized_coverage_plan.penalties.inspect