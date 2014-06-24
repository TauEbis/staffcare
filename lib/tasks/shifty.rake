namespace :shifty do
  task :sample_run => :environment do
    Dir['./app/models/shifty/*.rb'].each { |file| require file }
    Dir['./app/services/shifty/*.rb'].each { |file| require file }


    locations = [
        Location.new(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        Location.new(name: "CityMD_23rd_St", report_server_id: "CityMD_23th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        Location.new(name: "CityMD_57th_St", report_server_id: "CityMD_57th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        Location.new(name: "CityMD_67th_St", report_server_id: "CityMD_67th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        Location.new(name: "CityMD_86th_St", report_server_id: "CityMD_86th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        Location.new(name: "CityMD_88th_St", report_server_id: "CityMD_88th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
    ]

    schedule = Schedule.new(starts_on: Date.parse("2014-06-06"))

    grader_weights = { md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4 }

# Set contoller to use sample run CityMD visits data
    controller = CoveragePlansController.new(data_source: :sample_run)

# Create coverage plan with default data inputs. This will also create an optimized coverage option
    coverage_plan = controller.create(locations: locations, schedule: schedule, grader_weights: grader_weights)

# Print result of optimization to console
    optimized_coverage_plan = coverage_plan.optimized_graded_coverage_plan
    puts optimized_coverage_plan.coverages.inspect
    puts optimized_coverage_plan.penalties.inspect
  end

  task :run => :environment do
    Dir['./app/models/shifty/*.rb'].each { |file| require file }
    Dir['./app/services/shifty/*.rb'].each { |file| require file }

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
  end
end
