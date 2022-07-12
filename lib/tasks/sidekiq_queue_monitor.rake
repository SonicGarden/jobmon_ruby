namespace :jobmon do
  desc 'Ops monitor for Sidekiq queue for job-mon'
  task sidekiq_queue_monitor: :environment do
    require 'sidekiq/api'
    Rails.logger.info "[INFO] Start jobmon:sidekiq_queue_monitor env:#{Jobmon.configuration.release_stage}"
    stats = Sidekiq::Stats.new
    count = stats.queues.sum { |_, size| size }
    Jobmon::Client.new.send_queue_log(count)
    Jobmon::HealthcheckJob.perform_later
    Rails.logger.info "[INFO] End jobmon:sidekiq_queue_monitor env:#{Jobmon.configuration.release_stage}"
  end
end
