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

  if defined?(ActiveRecord::Base)
    c = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    c['pool']              = ENV['DB_POOL'] || 11
    c['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    ActiveRecord::Base.establish_connection(c)
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Status::ServerMiddleware, expiration: 1.day
  end
  config.client_middleware do |chain|
    chain.add Sidekiq::Status::ClientMiddleware
  end
end
