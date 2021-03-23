$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'jobmon'
require 'active_support/testing/time_helpers'

module Jobmon
  def self.available?
    true
  end
end

Jobmon::configure do |config|
  config.monitor_api_key = 'test_key'
  config.error_handle = -> (e) { raise e }
end

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
