class OptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(schedule_id)
    at 0, "Beginning"

    schedule = Schedule.find(schedule_id)
    schedule.running!

    provider = DataProvider.new(:sample_run)

    at 5, "Loading location plans"

    # Factory creates LocationPlans and VisitProjection
    factory = LocationPlansFactory.new({
                                           schedule: schedule,
                                           locations: Location.all,
                                           data_provider: provider})

    factory.create

    at 10, "Optimizing"

    schedule.optimize!

    at 100, "Optimizer finished"
    schedule.complete!
  end
end
