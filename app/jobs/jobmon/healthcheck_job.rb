class Jobmon::HealthcheckJob < ActiveJob::Base
  queue_as :default

  def perform
    Rails.logger.info 'healthcheck ok'
  end
end
