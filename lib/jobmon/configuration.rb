require 'socket'

module Jobmon
  class Configuration
    attr_accessor :monitor_api_key, :error_handle, :release_stage, :available_release_stages, :estimate_time,
      :logger, :endpoint, :hostname, :healthcheck_email_domain, :from_email, :parent_mailer, :default_task_job_queue

    def initialize
      self.endpoint = 'https://job-mon.sg-apps.com'
      self.healthcheck_email_domain = 'jobmon.sonicgarden.jp'
      self.error_handle = -> (e) {}
      self.release_stage = nil
      self.available_release_stages = %w[staging production]
      self.estimate_time = 3.minutes
      self.hostname = Socket.gethostname
      self.logger = Rails.logger
      self.parent_mailer = 'ApplicationMailer'
      self.default_task_job_queue = :default
    end

    def release_stage
      @release_stage || Rails.env
    end
  end
end
