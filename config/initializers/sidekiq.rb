require 'sidekiq-scheduler/web'
require 'sidekiq/throttled'
require 'sidekiq/throttled/web'

Sidekiq.configure_server do |config|
  config.options[:concurrency] = 20
  config.redis = { url: ENV['REDIS_SIDEKIQ_URL'] }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_SIDEKIQ_URL'] }
end

Sidekiq::Throttled::Web.enhance_queues_tab!

SidekiqAdhocJob.configure do |config|
  config.module_names =
    %w[
        Workers::Admin
        ImportNewsWorker
      ]
end

SidekiqAdhocJob.init
Sidekiq::Throttled.setup!
