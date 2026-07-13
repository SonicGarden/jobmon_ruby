require 'jobmon/errors'

module Jobmon
  module QueueCount
    module_function

    # 現在のActiveJobアダプタを自動判定してキュー滞留件数(Integer)を返す。
    # 判定できないアダプタ(inline/async/test/未知)はUnsupportedAdapterErrorを投げる。
    def call
      case adapter_name
      when 'delayed_job' then delayed_job
      when 'good_job'    then good_job
      when 'sidekiq'     then sidekiq
      when 'solid_queue' then solid_queue
      else
        raise Jobmon::UnsupportedAdapterError, "jobmon: unsupported queue adapter '#{adapter_name}'"
      end
    end

    def adapter_name
      ActiveJob::Base.queue_adapter_name.to_s
    end

    def delayed_job
      # NOTE: 実行遅延件数をカウント（上限一杯まで失敗したジョブは除く）
      Delayed::Job.where('run_at < ? AND failed_at IS NULL', Time.current).count
    end

    def good_job
      GoodJob::Job.queued.count
    end

    def sidekiq
      require 'sidekiq/api'
      Sidekiq::Stats.new.queues.sum { |_, size| size }
    end

    def solid_queue
      SolidQueue::ReadyExecution.count
    end
  end
end
