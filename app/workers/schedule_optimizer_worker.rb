class ScheduleOptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(schedule_id, opts={})
    at 0, "Beginning"

    schedule = Schedule.find(schedule_id)
    first_run = schedule.not_run?
    schedule.running!

    begin
      at 0, "Loading location plans"

      if first_run || opts['load_locations'] || opts['load_visits']
        # Factory creates/updates LocationPlans and VisitProjection
        factory = LocationPlansFactory.new( schedule: schedule, data_provider: DataProvider.new("database") )
        first_run ? factory.create : factory.update(opts)
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

      at num, "ScheduleOptimizer finished"
      schedule.complete!

    rescue ActiveRecord::RecordInvalid => exception
      at 0, exception.message
    rescue StandardError => exception
      at 0, exception.message
    end
  end
end
