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
        # Factory creates Grades and VisitProjection
        factory = GradeFactory.new( schedule: schedule, volume_source: schedule.volume_source.to_sym )
        first_run ? factory.create : factory.update(opts)
      end

      at 0, "Enqueuing GradeOptimizers"

      num = 0
      total schedule.grades.length

      schedule.grades.each do |grade|
        num += 1
        at num, "Enqueueing GradeOptimizers"
        job_id = GradeOptimizerWorker.perform_async(grade.id)
        grade.update_attribute(:optimizer_job_id, job_id)
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
