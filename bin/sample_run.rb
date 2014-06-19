#!/usr/bin/env ruby

require './bin/file_loader.rb'

	locations = [
		Location.new(name: "CityMD_23rd_St", max_mds: 4, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
	  Location.new(name: "CityMD_57th_St", max_mds: 4, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
	  Location.new(name: "CityMD_23rd_St", max_mds: 4, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
	  Location.new(name: "CityMD_67th_St", max_mds: 4, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
		Location.new(name: "CityMD_86th_St", max_mds: 5, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
	  Location.new(name: "CityMD_88th_St", max_mds: 5, rooms: 12, open: [9,8,8,8,8,8,9], close: [22,21,21,21,21,21,22]),
	]

	time_period = TimePeriod.new("2014-06-06", "2014-07-03")

	coverage = Coverage.new(locations: locations, time_period: time_period)

	optimized_coverage = coverage.optimized_graded_coverage

	puts optimized_coverage.shift_sets.inspect # Print result of optimization to console