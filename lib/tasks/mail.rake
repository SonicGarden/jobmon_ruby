namespace :jobmon do
  desc 'Send healthcheck mail'
  task send_healthcheck_mail: :environment do
    unless Jobmon.available?
      Rails.logger.info "[INFO] jobmon:send_healthcheck_mail is not available env:#{Jobmon.configuration.release_stage}"
      next
    end

    Rails.logger.info "[INFO] Start jobmon:send_healthcheck_mail env:#{Jobmon.configuration.release_stage}"
    Jobmon::Mailer.healthcheck.deliver_now
    Rails.logger.info "[INFO] End jobmon:send_healthcheck_mail env:#{Jobmon.configuration.release_stage}"
  end
end
