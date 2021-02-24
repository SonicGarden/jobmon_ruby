namespace :jobmon do
  desc 'Ops monitor for Delayed::Job queue for job-mon'
  task delayed_job_queue_monitor: :environment do
    Rails.logger.info "[INFO] Start jobmon:delayed_job_queue_monitor env:#{Rails.env}"
    # NOTE: 実行遅延件数をカウント（上限一杯まで失敗したジョブは除く）
    count = Delayed::Job.where('run_at < ? AND failed_at IS NULL', Time.current).count
    Jobmon::Client.new.send_queue_log(count)
    Jobmon::HealthcheckJob.perform_later
    Rails.logger.info "[INFO] End jobmon:delayed_job_queue_monitor env:#{Rails.env}"
  end
end
