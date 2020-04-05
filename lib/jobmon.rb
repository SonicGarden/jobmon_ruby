require 'rails'
require 'rake'
require 'faraday'
require 'faraday_middleware'
require 'jobmon/version'
require 'jobmon/client'
require 'jobmon/railtie'
require 'jobmon/configuration'
require 'jobmon/rake_monitor'

module Jobmon
  refine ::Rake::DSL do
    include RakeMonitor

    alias_method :task, :task_with_monitor
  end

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
