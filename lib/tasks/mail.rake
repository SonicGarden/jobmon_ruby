namespace :jobmon do
  desc 'Send healthcheck mail'
  task send_healthcheck_mail: :environment do
    Rails.logger.info "[INFO] Start jobmon:send_healthcheck_mail env:#{Rails.env}"
    Jobmon::Mailer.healthcheck.deliver_now
    Rails.logger.info "[INFO] End jobmon:send_healthcheck_mail env:#{Rails.env}"
  end
end
