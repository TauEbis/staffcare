worker_processes Integer(ENV['WEB_CONCURRENCY'] || 2)
timeout 20
preload_app true

before_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

  #if defined?(Resque)
  #  Resque.redis.quit
  #  Rails.logger.info('Disconnected from Redis')
  #end
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  if defined?(ActiveRecord::Base)
    c = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]

    c['pool']              = ENV['WEB_POOL'] || 3      # Each unicorn process can only use one connection.
                                                       # Mulitiply by worker_processes to get needed connections.
    c['reaping_frequency'] = ENV['DB_REAP_FREQ'] || 10 # seconds
    ActiveRecord::Base.establish_connection(c)
  end

  #if defined?(Resque)
  #  Resque.redis = ENV['<REDIS_URI>']
  #  Rails.logger.info('Connected to Redis')
  #end
end
