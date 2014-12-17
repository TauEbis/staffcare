require 'clockwork'
require './config/boot'
require './config/environment'

class ReportServerJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    ReportServerFactory.new.import!
  end

end

module Clockwork
  every 1.day, :if => lambda { |t| t.day == 19) do
    ReportServerJob.perform_async
  end
end

