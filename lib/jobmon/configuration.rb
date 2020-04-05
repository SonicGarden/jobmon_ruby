module Jobmon
  class Configuration
    attr_accessor :monitor_api_key, :error_handle, :available_release_stagings, :estimate_time

    def initialize
      @error_handle = -> (e) {}
      @available_release_stagings = %w[staging production]
      @estimate_time = 3.minutes
    end
  end
end
