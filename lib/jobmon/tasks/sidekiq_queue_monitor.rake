namespace :jobmon do
  desc 'Ops monitor for Sidekiq queue for job-mon'
  task sidekiq_queue_monitor: :environment do
    Rails.logger.info "[INFO] Start jobmon:sidekiq_queue_monitor env:#{Rails.env}"
    if defined?(Sidekiq)
      stats = Sidekiq::Stats.new
      count = stats.queues.sum { |_, size| size }
      Jobmon::Client.new.send_queue_log(count)
    end
    Rails.logger.info "[INFO] End jobmon:sidekiq_queue_monitor env:#{Rails.env}"
  end
end
