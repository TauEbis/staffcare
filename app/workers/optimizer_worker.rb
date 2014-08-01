class OptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(schedule_id)
    at 0, "Beginning"

    schedule = Schedule.find(schedule_id)
    schedule.running!

    source = Rails.env.development? ? :sample_run : "database"
    provider = DataProvider.new(source)

    at 0, "Loading location plans"

    # Factory creates LocationPlans and VisitProjection
    # Exclude Locations in the 'Unassigned' zone
    factory = LocationPlansFactory.new({
                                           schedule: schedule,
                                           locations: Location.assigned,
                                           data_provider: provider})

    factory.create

    at 0, "Optimizing"

    num = 0
    total schedule.total_length_to_optimize

    schedule.optimize! {
      num += 1
      at num, "Optimizing"
    }

    # TODO: After optimization we should generate shift coverages!

    # TODO: Bubble up Points to higher levels for cached viewing

    # TODO: Copy coverage from previous month and grade!

    at num, "Optimizer finished"
    schedule.complete!
  end
end
