namespace :jobmon do
  desc 'Send healthcheck mail'
  task send_healthcheck_mail: :environment do
    Rails.logger.info "[INFO] Start jobmon:send_healthcheck_mail env:#{Jobmon.configuration.release_stage}"
    Jobmon::Mailer.healthcheck.deliver_now
    Rails.logger.info "[INFO] End jobmon:send_healthcheck_mail env:#{Jobmon.configuration.release_stage}"
  end
end
