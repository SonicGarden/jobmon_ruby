# frozen_string_literal: true

if defined?(ActionMailer)
  class Jobmon::Mailer < ApplicationMailer
    default from: Jobmon.configuration.from_email if Jobmon.configuration.from_email

    def healthcheck
      to = "#{Jobmon.configuration.monitor_api_key}_#{Jobmon.configuration.release_stage}@#{Jobmon.configuration.healthcheck_email_domain}"
      mail(to: to, subject: 'Healthcheck', body: '')
    end
  end
end
