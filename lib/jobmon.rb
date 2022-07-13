require 'rails'
require 'rake'
require 'active_support/all'
require 'faraday'
require 'jobmon/version'
require 'jobmon/client'
require 'jobmon/engine'
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
      configuration.available_release_stages.include?(configuration.release_stage)
    end

    def with_options(options = {}, &block)
      orig_options = {}
      %i[estimate_time].each do |key|
        next unless options.key?(key)
        orig_options[key] = configuration.public_send(key)
        configuration.public_send("#{key}=", options[key])
      end
      yield
    ensure
      orig_options.each do |key, value|
        configuration.public_send("#{key}=", value)
      end
    end
  end
end
