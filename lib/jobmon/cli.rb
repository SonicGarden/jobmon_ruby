require 'optparse'
require 'rake'
require 'jobmon/client'

module Jobmon
  class CLI
    attr_reader :options, :task_argv

    def self.run(argv = ARGV)
      self.new(argv).run
    end

    def initialize(argv)
      @options = {}
      @task_argv = []
      parse_argv(argv)
    end

    def run
      task_argv.present? ? run_task : run_command
    end

    private

    def client
      Jobmon::Client.new
    end

    def run_command
      raise 'Command is empty.' if options[:cmd].nil?
      name = options.fetch(:name) { options[:cmd].split(' ', 2).first }

      client.job_monitor(name, estimate_time) do
        Kernel.system(options[:cmd])
        Process.last_status.exitstatus
      end
    end

    def run_task
      task, _ = Rake.application.parse_task_string(task_argv.first)
      name = options.fetch(:name) { task }

      client.job_monitor(name, estimate_time) do
        Rake.application.run(task_argv)
      end
      0
    end

    def estimate_time
      options.fetch(:estimate_time) { Jobmon.configuration.estimate_time }
    end

    def parse_argv(argv)
      task_argv.concat(opt.parse!(argv))
    end

    def opt
      OptionParser.new do |opts|
        opts.banner = "Usage: jobmon [options] task"
        opts.on('-e', '--estimate-time [time]') do |time|
          @options[:estimate_time] = time.to_i if time
        end
        opts.on('-n', '--name [name]') do |name|
          @options[:name] = name if name
        end
        opts.on('-t', '--task [task]') do |task|
          raise ArgumentError, "`--task` option is deprecated and will be removed in 0.5.0. "
        end
        opts.on('-c', '--cmd [cmd]') do |cmd|
          @options[:cmd] = cmd if cmd
        end
      end
    end
  end
end
