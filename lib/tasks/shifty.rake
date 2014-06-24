namespace :shifty do
  task :sample_run => :environment do
    z = Zone.create(name: 'NYC')

    locations = [
        z.locations.create!(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        z.locations.create!(name: "CityMD_23rd_St", report_server_id: "CityMD_23rd_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        z.locations.create!(name: "CityMD_57th_St", report_server_id: "CityMD_57th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        z.locations.create!(name: "CityMD_67th_St", report_server_id: "CityMD_67th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        z.locations.create!(name: "CityMD_86th_St", report_server_id: "CityMD_86th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
        z.locations.create!(name: "CityMD_88th_St", report_server_id: "CityMD_88th_St", max_mds: 3, rooms: 12, open_times: [9,8,8,8,8,8,9], close_times: [21,22,22,22,22,22,21]),
    ]

    schedule = Schedule.create!(starts_on: Date.parse("2014-06-06"), md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4, oren_shift: true)

    provider = DataProvider.new(:sample_run)

    # Factory creates LocationPlans and VisitProjection
    factory = LocationPlansFactory.new({
        schedule: schedule,
        locations: locations,
        data_provider: provider})

    factory.create

    schedule.optimize!

    # Print result of optimization to console
    schedule.location_plans.each do |lp|
      grade = lp.grades.order(id: :desc).first
      puts grade.coverages.inspect
      puts grade.penalties.inspect
    end
  end

  task :dummy_run => :environment do
    z = Zone.create(name: 'NYC')

    locations = [
        z.locations.create!(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [8,8,8,8,8,8,8], close_times: [22,22,22,22,22,22,22]),
    ]

    schedule = Schedule.create!(starts_on: Date.parse("2014-06-06"), md_rate: 4.25, penalty_slack: 2.5, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4, oren_shift: true)

    provider = DataProvider.new(:dummy)

    # Factory creates LocationPlans and VisitProjection
    factory = LocationPlansFactory.new({
                                           schedule: schedule,
                                           locations: locations,
                                           data_provider: provider})

    factory.create

    schedule.optimize!

    # Print result of optimization to console
    schedule.location_plans.reload.each do |lp|
      grade = lp.grades.order(id: :desc).first
      puts grade.coverages.inspect
      puts grade.penalties.inspect
    end
  end
end
