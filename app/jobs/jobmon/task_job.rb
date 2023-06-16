# frozen_string_literal: true

require 'shellwords'
require 'open3'

# ActiveJobバックエンドのスケジューラからの呼び出し用
class Jobmon::TaskJob < ActiveJob::Base
  queue_as Jobmon.configuration.task_job_queue

  def perform(task:, estimate_time: nil, name: nil)
    options = {
      estimate_time: estimate_time,
      name: name,
    }.compact.flat_map { |k, v| ["--#{k.to_s.dasherize}", v.to_s] }

    out, error, status = Open3.capture3(
      'bundle',
      'exec',
      'jobmon',
      *options,
      *Shellwords.shellwords(task),
      chdir: Rails.root.to_s
    )

    raise Jobmon::TaskJobError.new(error) unless status.success?
  end
end
