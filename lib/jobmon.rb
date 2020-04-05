require 'rails'
require 'faraday'
require 'faraday_middleware'
require 'jobmon/version'
require 'jobmon/client'
require 'jobmon/railtie'
require 'jobmon/configuration'

module Jobmon
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def available?
      configuration.available_release_stagings.include?(Rails.env)
    end
  end
end
