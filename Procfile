web: bundle exec bin/rails server -b 0.0.0.0 -p ${PORT}
worker: bundle exec sidekiq -C config/sidekiq.yml
release: bundle exec rails db:migrate