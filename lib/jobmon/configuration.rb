module Jobmon
  class Configuration
    attr_accessor :monitor_api_key, :error_handle, :available_release_stagings, :estimate_time, :logger, :endpoint

    def initialize
      self.endpoint = 'https://job-mon.sg-apps.com'
      self.error_handle = -> (e) {}
      self.available_release_stagings = %w[staging production]
      self.estimate_time = 3.minutes
    end
  end
end
