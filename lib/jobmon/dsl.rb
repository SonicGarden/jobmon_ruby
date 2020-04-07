require 'jobmon/client'
require 'jobmon/task'
require 'jobmon/task_monitor'

module Jobmon
  module DSL
    private

    def jobmon(options = {}, &block)
      Jobmon.with_options(options) do
        TaskMonitor.new.instance_exec(&block)
      end
    end

    def task_with_monitor(*args, &block)
      args, options = __jobmon_resolve_args(args)
      Task::define_task(options, args, &block)
    end

    def __jobmon_resolve_args(args)
      options = args.last.is_a?(Hash) ? args.last : {}
      estimate_time = options.delete(:estimate_time) { Jobmon.configuration.estimate_time }
      skip_jobmon_available_check = options.delete(:skip_jobmon_available_check) { Jobmon.configuration.skip_jobmon_available_check }

      [args, { estimate_time: estimate_time, skip_jobmon_available_check: skip_jobmon_available_check }]
    end
  end
end
