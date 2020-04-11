require 'jobmon/client'

module Jobmon
  class CLI
    def self.run(*args)
      self.new(*args).run
    end

    def initialize(argv, options)
      @argv = argv
      @options = options
    end

    def run
      client.job_monitor(name, estimate_time) do
        Kernel.system(*@argv)
        Process.last_status.exitstatus
      end
    end

    private

    def client
      Jobmon::Client.new
    end

    def name
      @options.fetch(:name) { @argv[0] }
    end

    def estimate_time
      @options.fetch(:estimate_time) { Jobmon.configuration.estimate_time }
    end
  end
end
