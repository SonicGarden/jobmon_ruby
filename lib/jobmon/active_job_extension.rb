module Jobmon
  module ActiveJobExtension
    extend ActiveSupport::Concern

    included do
      class_attribute :jobmon_config, instance_accessor: false, default: {}

      around_perform do |job, block|
        job_name = job.class.jobmon_config.fetch(:name) { job.class.name }
        estimate_time = job.class.jobmon_config.fetch(:estimate_time) { Jobmon.configuration.estimate_time }

        Jobmon::Client.new.job_monitor(job_name, estimate_time) do
          block.call
        end
      end
    end

    class_methods do
      def jobmon_with(config)
        self.jobmon_config = config
      end
    end
  end
end
