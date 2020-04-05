module Jobmon
  class Task
    def self.define_task(options, args, &block)
      if Jobmon.available? || options[:skip_jobmon_available_check]
        task = Rake::Task.define_task(*args) do |_task, _args|
          client.job_monitor(_task.name, _task.estimate_time) do |job_id|
            log(_task, job_id, _args, :started)
            yield(_task, _args)
            log(_task, job_id, _args, :finished)
          end
        end
        task.singleton_class.class_eval { attr_accessor :estimate_time }
        task.estimate_time = options.fetch(:estimate_time)
        task
      else
        Rake::Task.define_task(*args)
      end
    end

    def self.client
      @client ||= Jobmon::Client.new
    end

    def self.log(task, job_id, args, type, &block)
      Jobmon.configuration.logger.info "[#{task.timestamp}][JobMon][INFO] #{task.name} (job_id: #{job_id}, estimate_time: #{task.estimate_time}, args: #{args.to_h}) #{type} }."
    end
  end
end
