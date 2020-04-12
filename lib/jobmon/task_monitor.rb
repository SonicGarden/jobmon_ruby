require 'jobmon/task'

module Jobmon
  class TaskMonitor
    include ::Rake::DSL

    def task(*args, &block)
      options = { estimate_time: Jobmon.configuration.estimate_time }
      Task::define_task(options, args, &block)
    end
  end
end
