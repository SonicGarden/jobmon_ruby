module Jobmon
  class Configuration
    attr_accessor :monitor_api_key, :error_handle, :available_release_stagings, :estimate_time, :skip_jobmon_available_check, :logger

    def initialize
      self.error_handle = -> (e) {}
      self.available_release_stagings = %w[staging production]
      self.estimate_time = 3.minutes
      self.skip_jobmon_available_check = false
      self.logger = Rails.logger
    end
  end
end
