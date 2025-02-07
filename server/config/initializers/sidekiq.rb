require 'sidekiq'
require 'sidekiq/web'

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/1') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://redis:6379/1') }
end

# Schedule periodic jobs
Sidekiq::Cron::Job.create(
  name: 'Cleanup stale tasks - every 5 minutes',
  cron: '*/5 * * * *',
  class: 'CleanupStaleTasksJob'
)