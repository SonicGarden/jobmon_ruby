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

      if Jobmon.available?
        task *args do |t|
          job_id = client.job_start(t, estimate_time)
          log(t, job_id, :started)
          begin
            block.call(t)
          ensure
            log(t, job_id, :finished)
            client.job_end(job_id)
          end
        end
      else
        task *args do |t|
          block.call(t)
        end
      end
    end

    def log(task, job_id, type)
      if defined?(Rails) && Rails.logger
        Rails.logger.info "[#{task.timestamp}][JobMon][INFO] #{task.name} (job_id: #{job_id}) #{type.to_s}."
      end
    end
  end
end

self.extend Jobmon::RakeMonitor
