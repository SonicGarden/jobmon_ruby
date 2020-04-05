$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "jobmon"

module Jobmon
  def self.available?
    true
  end
end

Jobmon::configure do |config|
  config.monitor_api_key = 'test_key'
end
