namespace :jobmon do
  desc '[DEPRECATED] Use jobmon:queue_monitor instead'
  task delayed_job_queue_monitor: :environment do
    Rake::Task['jobmon:queue_monitor'].invoke
  end
end
