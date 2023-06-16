require 'spec_helper'
require "active_job"
require_relative '../../../app/jobs/jobmon/task_job'

ActiveJob::Base.queue_adapter = :test
ActiveJob::Base.logger = ActiveSupport::Logger.new(nil)

describe Jobmon::TaskJob do
  describe '#perform' do
    context 'success' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', '', double(success?: true)])
      end

      it 'run task' do
        Jobmon::TaskJob.perform_now(task: 'test')
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', 'test', anything)
      end

      it 'run task with env' do
        Jobmon::TaskJob.perform_now(task: 'test ID=1')
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', 'test', 'ID=1', anything)
      end

      it 'run task with args' do
        Jobmon::TaskJob.perform_now(task: 'test "hello world"')
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', 'test', 'hello world', anything)
      end

      it 'run task with estimate_time options' do
        Jobmon::TaskJob.perform_now(task: 'test', estimate_time: 30)
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', '--estimate-time', '30', 'test', anything)
      end

      it 'run task with name options' do
        Jobmon::TaskJob.perform_now(task: 'test', name: 'dummy')
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', '--name', 'dummy', 'test', anything)
      end

      it 'run task with estimate_time and name options' do
        Jobmon::TaskJob.perform_now(task: 'test', estimate_time: 30, name: 'dummy')
        expect(Open3).to have_received(:capture3).with('bundle', 'exec', 'jobmon', '--estimate-time', '30', '--name', 'dummy', 'test', anything)
      end
    end

    context 'failure' do
      before do
        allow(Open3).to receive(:capture3).and_return(['', 'error', double(success?: false)])
      end

      it 'raise Jobmon::TaskJobError' do
        expect { Jobmon::TaskJob.perform_now(task: 'test') }.to raise_error(Jobmon::TaskJobError)
      end
    end
  end
end
