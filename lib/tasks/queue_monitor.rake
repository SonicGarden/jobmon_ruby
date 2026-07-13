namespace :jobmon do
  desc 'Ops monitor for the current ActiveJob queue adapter for job-mon'
  task queue_monitor: :environment do
    next unless Jobmon.available?

    Jobmon::Client.new.send_queue_log(Jobmon::QueueCount.call)
  end
end
