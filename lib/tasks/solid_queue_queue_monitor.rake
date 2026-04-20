namespace :jobmon do
  desc 'Ops monitor for solid_queue queue for job-mon'
  task solid_queue_queue_monitor: :environment do
    unless Jobmon.available?
      Rails.logger.info "[INFO] jobmon:solid_queue_queue_monitor is not available env:#{Jobmon.configuration.release_stage}"
      next
    end

    Rails.logger.info "[INFO] Start jobmon:solid_queue_queue_monitor env:#{Jobmon.configuration.release_stage}"
    Jobmon::Client.new.send_queue_log(SolidQueue::ReadyExecution.count)
    Jobmon::HealthcheckJob.perform_later
    Rails.logger.info "[INFO] End jobmon:solid_queue_queue_monitor env:#{Jobmon.configuration.release_stage}"
  end
end
