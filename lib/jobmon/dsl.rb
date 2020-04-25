require 'jobmon/client'
require 'jobmon/task'
require 'jobmon/task_monitor'

module Jobmon
  module DSL
    private

    def jobmon(options = {}, &block)
      ActiveSupport::Deprecation.warn(
        "`jobmon` DSL is deprecated and will be removed in 0.5.0. " \
        "Please use `jobmon` cli instead"
      )

      Jobmon.with_options(options) do
        TaskMonitor.new.instance_exec(&block)
      end
    end

    def task_with_monitor(*args, &block)
      ActiveSupport::Deprecation.warn(
        "`task_with_monitor` DSL is deprecated and will be removed in 0.5.0. " \
        "Please use `jobmon` cli instead"
      )

      args, options = __jobmon_resolve_args(args)
      Task::define_task(options, args, &block)
    end

    def __jobmon_resolve_args(args)
      options = args.last.is_a?(Hash) ? args.last : {}
      estimate_time = options.delete(:estimate_time) { Jobmon.configuration.estimate_time }

      [args, { estimate_time: estimate_time }]
    end
  end
end
