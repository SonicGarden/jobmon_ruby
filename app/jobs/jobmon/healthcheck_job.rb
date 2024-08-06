class Jobmon::HealthcheckJob < ActiveJob::Base
  queue_as Jobmon.configuration.healthcheck_job_queue

  def perform
    Rails.logger.info 'healthcheck ok'
  end
end
