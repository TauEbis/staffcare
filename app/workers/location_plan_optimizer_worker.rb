class LocationPlanOptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(location_plan_id)
    at 0, "Beginning"

    location_plan = LocationPlan.find(location_plan_id)
    location_plan.running!

    begin
      at 0, "Optimizing"

      optimizer = LocationPlanOptimizer.new(location_plan)

      num = 0
      total location_plan.schedule.days.length

      optimizer.optimize! {
        num += 1
        at num, "Optimizing"
      }

      # TODO: Copy coverage from previous month and grade!

      at num, "LocationPlanOptimizer finished"
      location_plan.complete!

    rescue ActiveRecord::RecordInvalid => exception
      at 0, exception.message
    rescue StandardError => exception
      at 0, exception.message
    end
  end
end
