class PushWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(push_id)
    at 0, "Beginning"
    num = 0

    push = Push.find(push_id)

    push.presync!
    at 0, "Pre Syncing"

    wiw_pusher = WiwPusher.new(push)

    push.running!
    total push.total_length

    wiw_pusher.push! {
      num += 1
      at num, "Syncing"
    }

    at num, "Finished"
    push.complete!
  end
end
