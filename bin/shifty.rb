#!/usr/bin/env ruby

## this file is only useful for command line testing

require './bin/file_loader.rb'

	coverage = Coverage.new # Create new coverage map with default values and run optimization

	optimized_coverage = coverage.optimized_graded_coverage

	puts optimized_coverage.shift_sets.inspect # Print result of optimization to console
	puts optimized_coverage.penalties.inspect