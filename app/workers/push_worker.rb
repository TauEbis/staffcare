class PushWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(push_id)
    at 0, "Beginning"

    push = Push.find(push_id)
    push.running!

    wiw_pusher = WiwPusher.new(push)

    total push.total_length
    num = 0

    wiw_pusher.push! {
      num += 1
      at num, "Syncing"
    }

    at num, "Finished"
    push.complete!
  end
end
