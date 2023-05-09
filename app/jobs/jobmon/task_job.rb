# frozen_string_literal: true

# ActiveJobバックエンドのスケジューラからの呼び出し用
class Jobmon::TaskJob < ActiveJob::Base
  queue_as Jobmon.configuration.default_task_job_queue

  # TODO: test
  def perform(task:, estimate_time: nil, name: nil)
    options = {
      estimate_time: estimate_time,
      name: name,
    }.compact.map { |k, v| "--#{k.to_s.dasherize} #{v}" }.join(' ')

    Kernel.system(
      "bundle exec jobmon #{options} #{task}",
      exception: true,
      chdir: Rails.root.to_s
    )
  end
end
