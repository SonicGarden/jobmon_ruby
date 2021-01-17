require 'socket'

module Jobmon
  class Configuration
    attr_accessor :monitor_api_key, :error_handle, :available_release_stagings, :estimate_time, :logger, :endpoint, :hostname

    def initialize
      self.endpoint = 'https://job-mon.sg-apps.com'
      self.error_handle = -> (e) {}
      self.available_release_stagings = %w[staging production]
      self.estimate_time = 3.minutes
      self.hostname = Socket.gethostname
      self.logger = Rails.logger
    end
  end
end
