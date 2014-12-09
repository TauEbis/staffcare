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

    locations.each do |location|
      location.speeds.create(doctors: 1, normal: 4, max: 6)
      location.speeds.create(doctors: 2, normal: 8, max: 12)
      location.speeds.create(doctors: 3, normal: 12, max: 18)
      location.speeds.create(doctors: 4, normal: 16, max: 24)
      location.speeds.create(doctors: 5, normal: 20, max: 30)
    end

    schedule = Schedule.create!(starts_on: Date.parse("2014-06-06"), md_hourly: 10, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4)

    provider = DataProvider.new(:sample_run)

    # Factory creates LocationPlans and VisitProjection
    factory = GradeFactory.new({
        schedule: schedule,
        locations: locations,
        data_provider: provider})

    factory.create

    schedule.optimize!

    # Print result of optimization to console
    schedule.location_plans.each do |lp|
      grade = lp.grades.order(id: :desc).first
      puts grade.coverages.inspect
      puts grade.breakdowns.inspect
      puts grade.shifts.inspect
    end
  end

  task :dummy_run => :environment do

    z = Zone.create(name: 'NYC')

    locations = [
        z.locations.create!(name: "CityMD_14th_St", report_server_id: "CityMD_14th_St", max_mds: 3, rooms: 12, open_times: [8,8,8,8,8,8,8], close_times: [22,22,22,22,22,22,22]),
    ]

    locations.each do |location|
      location.speeds.create(doctors: 1, normal: 4, max: 6)
      location.speeds.create(doctors: 2, normal: 8, max: 12)
      location.speeds.create(doctors: 3, normal: 12, max: 18)
      location.speeds.create(doctors: 4, normal: 16, max: 24)
      location.speeds.create(doctors: 5, normal: 20, max: 30)
    end

    schedule = Schedule.create!(starts_on: Date.parse("2014-06-06"), md_hourly: 10, penalty_30min: 1, penalty_60min: 4, penalty_90min: 16, penalty_eod_unseen: 4)
    schedule.custom_length(0)
    schedule.save

    provider = DataProvider.new(:dummy)
    # Factory creates LocationPlans and VisitProjection
    factory = GradeFactory.new({
                                           schedule: schedule,
                                           locations: locations,
                                           data_provider: provider})

    factory.create

    schedule.optimize!

    # Print result of optimization to console
    schedule.location_plans.reload.each do |lp|
      grade = lp.grades.order(id: :desc).first
      puts grade.coverages.inspect
      puts grade.breakdowns.inspect
      puts grade.shifts.inspect
    end

  end
end
