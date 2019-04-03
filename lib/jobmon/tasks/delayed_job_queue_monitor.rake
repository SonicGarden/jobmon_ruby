namespace :jobmon do
  desc 'Ops monitor for Delayed::Job queue for job-mon'
  task delayed_job_queue_monitor: :environment do
    return unless Jobmon.available?

    Rails.logger.info "[INFO] Start jobmon:delayed_job_queue_monitor env:#{Rails.env}"
    if defined?(Delayed::Job)
      count = Delayed::Job.where('run_at < ? or last_error IS NOT NULL', 30.seconds.since).count
      Jobmon::Client.new.send_queue_log(count)
    end
    Rails.logger.info "[INFO] End jobmon:delayed_job_queue_monitor env:#{Rails.env}"
  end
end
