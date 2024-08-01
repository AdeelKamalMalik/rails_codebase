# inside config/initializers/sidekiq.rb

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, db: ENV.fetch('REDIS_DB', 1) }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }, db: ENV.fetch('REDIS_DB', 1) }
end
