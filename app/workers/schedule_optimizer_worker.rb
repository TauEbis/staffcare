class ScheduleOptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(schedule_id, opts={})
    at 0, "Beginning"

    schedule = Schedule.find(schedule_id)
    rerun = schedule.complete? # for updates
    schedule.running!

    begin

      unless opts[:skip_locations] && opts[:skip_visits]
        source = "database" # Set to :sample_run for sample data. On a dev machine, rake rs_load adds heatmaps to the database.
        provider = DataProvider.new(source)

        at 0, "Loading location plans"

        # Factory creates LocationPlans and VisitProjection
        # Exclude Locations in the 'Unassigned' zone
        factory = LocationPlansFactory.new({
                                               schedule: schedule,
                                               locations: rerun ? Location.for_schedule(schedule) : Location.assigned ,
                                               data_provider: provider})

        rerun ? factory.update(opts) : factory.create

      end

      at 0, "Enqueuing LocationPlanOptimizers"

      num = 0
      total schedule.location_plans.length

      schedule.location_plans.each do |location_plan|
        num += 1
        at num, "Enqueueing LocationPlanOptimizers"
        job_id = LocationPlanOptimizerWorker.perform_async(location_plan.id)
        location_plan.update_attribute(:optimizer_job_id, job_id)
      end

      # TODO: After optimization we should generate shift coverages!

      # TODO: Bubble up Points to higher levels for cached viewing

      # TODO: Copy coverage from previous month and grade!

      at num, "ScheduleOptimizer finished"
      schedule.complete!

    rescue ActiveRecord::RecordInvalid => exception
      at 0, exception.message
    rescue StandardError => exception
      at 0, exception.message
    end
  end
end
