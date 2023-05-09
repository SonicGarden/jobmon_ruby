require 'spec_helper'
require "active_job"
require_relative '../../../app/jobs/jobmon/task_job'

ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = ActiveSupport::Logger.new(nil)

describe Jobmon::TaskJob do
  describe '#perform' do
    before do
      allow(Kernel).to receive(:system)
    end

    it 'run task' do
      Jobmon::TaskJob.perform_now(task: 'test')
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', 'test', anything)
    end

    it 'run task with env' do
      Jobmon::TaskJob.perform_now(task: 'test ID=1')
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', 'test', 'ID=1', anything)
    end

    it 'run task with args' do
      Jobmon::TaskJob.perform_now(task: 'test "hello world"')
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', 'test', 'hello world', anything)
    end

    it 'run task with estimate_time options' do
      Jobmon::TaskJob.perform_now(task: 'test', estimate_time: 30)
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', '--estimate-time', '30', 'test', anything)
    end

    it 'run task with name options' do
      Jobmon::TaskJob.perform_now(task: 'test', name: 'dummy')
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', '--name', 'dummy', 'test', anything)
    end

    it 'run task with estimate_time and name options' do
      Jobmon::TaskJob.perform_now(task: 'test', estimate_time: 30, name: 'dummy')
      expect(Kernel).to have_received(:system).with('bundle', 'exec', 'jobmon', '--estimate-time', '30', '--name', 'dummy', 'test', anything)
    end
  end
end
