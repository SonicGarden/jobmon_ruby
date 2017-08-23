namespace :jobmon do
  desc 'Send a test job to job-mon'
  task_with_monitor test_job: :environment, estimate_time: 10 do
  end
end
