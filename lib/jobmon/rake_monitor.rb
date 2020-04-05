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

      task *args do |_task, _args|
        if Jobmon.available? || options[:skip_jobmon_available_check]
          client.job_monitor(_task, options[:estimate_time]) do |job_id|
            log(_task, job_id, _args, :started)
            yield(_task, _args)
            log(_task, job_id, _args, :finished)
          end
        else
          yield(_task, _args)
        end
      end
    end

    def log(task, job_id, _args, type)
      if defined?(Rails) && Rails.logger
        Rails.logger.info "[#{task.timestamp}][JobMon][INFO] #{task.name} (job_id: #{job_id}) #{type.to_s} #{_args.to_h}."
      end
    end
  end
end

self.extend Jobmon::RakeMonitor
