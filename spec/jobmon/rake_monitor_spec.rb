require 'spec_helper'
require 'ostruct'

require 'jobmon/rake_monitor'

describe Jobmon::RakeMonitor do
  module SampleModule
    extend Jobmon::RakeMonitor

    def self.client=(client)
      @__jobmon_client = client
    end
  end

  before do
    Rake::Task.define_task(:environment) {}
  end

  after do
    Rake::Task.clear
  end

  context 'without error' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('sample', 10.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      task = SampleModule.send(:task_with_monitor, sample: :environment, estimate_time: 10.minutes) {}
      task.invoke
    end
  end

  context 'with error' do
    it 'calls #job_start and #job_end and raise error' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      expect {
        task = SampleModule.send(:task_with_monitor, sample: :environment, estimate_time: 10.minutes) { raise 'test' }
        task.invoke
      }.to raise_error(RuntimeError, 'test')
    end
  end

  context 'with args' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('sample', 10.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      task = SampleModule.send(:task_with_monitor, :sample, [:arg1, :arg2] => :environment, estimate_time: 10.minutes) {}
      task.invoke
    end
  end

  context 'default estimate_time' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('sample', 3.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      task = SampleModule.send(:task_with_monitor, sample: :environment) {}
      task.invoke
    end
  end

  context 'no options' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('sample', 3.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      task = SampleModule.send(:task_with_monitor, :sample) {}
      task.invoke
    end
  end
end
