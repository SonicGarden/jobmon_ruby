module Jobmon
  module RakeMonitor
    def resolve_args(args)
      options = args.last.is_a?(Hash) ? args.last : {}
      estimate_time = options.delete(:estimate_time) { Jobmon.configuration.estimate_time }
      skip_jobmon_available_check = options.delete(:skip_jobmon_available_check) { false }

      [args, { estimate_time: estimate_time, skip_jobmon_available_check: skip_jobmon_available_check }]
    end

    def client
      @client ||= Jobmon::Client.new
    end

    def task_with_monitor(*args, &block)
      args, options = resolve_args(args)

      if Jobmon.available? || options[:skip_jobmon_available_check]
        task *args do |t|
          job_id = client.job_start(t, options[:estimate_time])
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
