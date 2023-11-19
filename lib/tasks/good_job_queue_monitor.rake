namespace :jobmon do
  desc 'Ops monitor for good_job queue for job-mon'
  task good_job_queue_monitor: :environment do
    unless Jobmon.available?
      Rails.logger.info "[INFO] jobmon:good_job_queue_monitor is not available env:#{Jobmon.configuration.release_stage}"
      next
    end

    Rails.logger.info "[INFO] Start jobmon:good_job_queue_monitor env:#{Jobmon.configuration.release_stage}"
    Jobmon::Client.new.send_queue_log(GoodJob::Job.queued.count)
    Jobmon::HealthcheckJob.perform_later
    Rails.logger.info "[INFO] End jobmon:good_job_queue_monitor env:#{Jobmon.configuration.release_stage}"
  end
end
