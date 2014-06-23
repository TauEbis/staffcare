#!/usr/bin/env ruby

## This file is only useful for command line testing

require './bin/shifty_file_loader.rb'

	controller = CoveragePlansController.new

# Create coverage plan with default data inputs. This will also create an optimized coverage option
	coverage_plan = controller.create
#	coverage_plan = controller.update(reload: true)

# Print result of optimization to console
	optimized_coverage_plan = coverage_plan.optimized_graded_coverage_plan
	puts optimized_coverage_plan.coverages.inspect
	puts optimized_coverage_plan.penalties.inspect

=begin
# Uncomment this section to print chosen coverage plan grades
	coverage_plan.grade_chosen_coverage_plan
	chosen_coverage_plan = coverage_plan.chosen_coverage_plan
	puts chosen_coverage_plan.coverages.inspect
	puts chosen_coverage_plan.penalties.inspect
=end