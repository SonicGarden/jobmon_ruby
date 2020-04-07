jobmon estimate_time: 10, skip_jobmon_available_check: true do
  namespace :jobmon do
    desc 'Send a test job to job-mon'
    task test_job: :environment do
    end
  end
end
