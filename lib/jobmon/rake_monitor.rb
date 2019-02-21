module Jobmon
  module RakeMonitor
    def resolve_args(args)
      estimate_time = args.first.delete(:estimate_time)
      [args, estimate_time]
    end

    def client
      @client ||= Jobmon::Client.new
    end

    def task_with_monitor(*args, &block)
      args, estimate_time = resolve_args(args)
      task *args do |t|
        job_id = client.job_start(t, estimate_time)
        log "[JobMon][INFO] job_id: #{job_id} started."
        begin
          block.call(t)
        ensure
          log "[JobMon][INFO] job_id: #{job_id} finished."
          client.job_end(job_id)
        end
      end
    end

    def log(message)
      if defined?(Rails) && Rails.logger
        Rails.logger.info message
      end
    end
  end
end

self.extend Jobmon::RakeMonitor
