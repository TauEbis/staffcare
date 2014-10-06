class LocationPlanOptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(location_plan_id, opts={})
    at 0, "Beginning"

    location_plan = LocationPlan.find(location_plan_id)
    rerun = location_plan.complete? # for updates
    location_plan.running!

    begin
      at 0, "Optimizing"

      optimizer = LocationPlanOptimizer.new(location_plan)

      num = 0
      total optimizer.days.length

      optimizer.optimize! {
        num += 1
        at num, "Optimizing"
      }

      # TODO: After optimization we should generate shift coverages!

      # TODO: Bubble up Points to higher levels for cached viewing

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
