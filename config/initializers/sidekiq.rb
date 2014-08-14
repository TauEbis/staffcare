require 'sidekiq'
require 'sidekiq-status'

Sidekiq.configure_client do |config|
  config.redis = {
      namespace: "staff_care_#{Rails.env}"
  }

  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end


Sidekiq.configure_server do |config|
  config.redis = {
    namespace: "staff_care_#{Rails.env}"
  }

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 1.day
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end
