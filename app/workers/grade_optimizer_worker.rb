class GradeOptimizerWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  sidekiq_options retry: false

  def perform(grade)
    at 0, "Beginning"

    grade = Grade.find(grade)
    grade.running!

    begin
      at 0, "Optimizing"

      optimizer = GradeOptimizer.new(grade)

      num = 0
      total grade.days.length

      optimizer.optimize! {
        num += 1
        at num, "Optimizing"
      }

      # TODO: Copy coverage from previous month and grade!

      at num, "GradeOptimizer finished"
      grade.complete!

    rescue ActiveRecord::RecordInvalid => exception
      at 0, exception.message
    rescue StandardError => exception
      at 0, exception.message
    end
  end
end
