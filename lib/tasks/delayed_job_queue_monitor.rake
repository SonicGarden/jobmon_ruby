namespace :jobmon do
  desc 'Ops monitor for Delayed::Job queue for job-mon'
  task delayed_job_queue_monitor: :environment do
    Rails.logger.info "[INFO] Start jobmon:delayed_job_queue_monitor env:#{Rails.env}"
    count = Delayed::Job.where('run_at < ?', 30.seconds.since).count
    Jobmon::Client.new.send_queue_log(count)
    Jobmon::HealthcheckJob.perform_later
    Rails.logger.info "[INFO] End jobmon:delayed_job_queue_monitor env:#{Rails.env}"
  end
end
