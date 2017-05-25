module Jobmon
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'jobmon/tasks/delayed_job_queue_monitor.rake'
    end
  end
end
