module Jobmon
  class Railtie < ::Rails::Railtie
    rake_tasks do
      require 'jobmon/tasks/preload'
      load 'jobmon/tasks/delayed_job_queue_monitor.rake'
      load 'jobmon/tasks/sidekiq_queue_monitor.rake'
    end
  end
end
