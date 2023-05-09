# frozen_string_literal: true

require 'shellwords'

# ActiveJobバックエンドのスケジューラからの呼び出し用
class Jobmon::TaskJob < ActiveJob::Base
  queue_as Jobmon.configuration.default_task_job_queue

  def perform(task:, estimate_time: nil, name: nil)
    options = {
      estimate_time: estimate_time,
      name: name,
    }.compact.flat_map { |k, v| ["--#{k.to_s.dasherize}", v.to_s] }

    Kernel.system(
      'bundle',
      'exec',
      'jobmon',
      *options,
      *Shellwords.shellwords(task),
      exception: true,
      chdir: Rails.root.to_s
    )
  end
end
