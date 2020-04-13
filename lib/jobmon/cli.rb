require 'optparse'
require 'rake'
require 'jobmon/client'

module Jobmon
  class CLI
    attr_reader :options, :cmd

    def self.run(argv)
      self.new(argv).run
    end

    def initialize(argv)
      @options = {}
      @cmd = []
      parse_argv(argv)
    end

    def run
      options[:task].present? ? run_task(options[:task]) : run_command
    end

    private

    def client
      Jobmon::Client.new
    end

    def run_command
      raise 'Command is empty.' if cmd.empty?

      client.job_monitor(name, estimate_time) do
        Kernel.system(*cmd)
        Process.last_status.exitstatus
      end
    end

    def run_task(string)
      Rake.application.load_rakefile
      task, args = Rake.application.parse_task_string(string)

      client.job_monitor(task, estimate_time) do
        Rake::Task[task].invoke(*args)
      end
      0
    end

    def name
      options.fetch(:name) { cmd[0] }
    end

    def estimate_time
      options.fetch(:estimate_time) { Jobmon.configuration.estimate_time }
    end

    def parse_argv(argv)
      cmd_index = argv.index.with_index do |v, i|
        if v.start_with?('-')
          false
        else
          prev = argv[i - 1]
          !prev.start_with?('-') || prev.include?('=')
        end
      end
      cmd_index = argv.size - 1 if cmd_index.nil?

      jobmon_options = argv.slice(0..cmd_index)
      @cmd = argv.slice(cmd_index..-1)
      opt.parse!(jobmon_options)
    end

    def opt
      OptionParser.new do |opts|
        opts.banner = "Usage: jobmon [options] command"
        opts.on('-e', '--estimate-time [time]') do |time|
          @options[:estimate_time] = time.to_i if time
        end
        opts.on('-n', '--name [name]') do |name|
          @options[:name] = name if name
        end
        opts.on('-t', '--task [task]') do |task|
          @options[:task] = task if task
        end
      end
    end
  end
end
