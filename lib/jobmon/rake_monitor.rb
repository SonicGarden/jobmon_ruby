module Jobmon
  module RakeMonitor
    def resolve_args(args)
      estimate_time = args.first.delete(:estimate_time)
      [args, estimate_time]
    end

    def client
      @client ||= Jobmon::Client.new
    end

    def monitor_email
      Jobmon.configure.monitor_email
    end

    def task_with_monitor(*args, &block)
      args, estimate_time = resolve_args(args)
      task *args do |t|
        job_id = client.job_start(t, estimate_time, monitor_email)
        block.call
        client.job_end(job_id)
      end
    end
  end
end

self.extend Jobmon::RakeMonitor
