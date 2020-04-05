require 'spec_helper'
require 'ostruct'

require 'jobmon/rake_monitor'

describe Jobmon::RakeMonitor do
  module SampleModule
    extend Jobmon::RakeMonitor

    SampleTask = Struct.new(:name)

    def self.client=(client)
      @client = client
    end

    def self.task(*)
      yield SampleTask.new('test')
    end
  end

  context 'without error' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('test', 10.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      SampleModule.task_with_monitor(sample: :development, estimate_time: 10.minutes) {}
    end
  end

  context 'with error' do
    it 'calls #job_start and #job_end and raise error' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      expect {
        SampleModule.task_with_monitor(sample: :development, estimate_time: 10.minutes) { raise 'test' }
      }.to raise_error(RuntimeError, 'test')
    end
  end

  context 'with args' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('test', 10.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      SampleModule.task_with_monitor(:sample, [:arg1, :arg2] => :development, estimate_time: 10.minutes) {}
    end
  end

  context 'default estimate_time' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('test', 3.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      SampleModule.task_with_monitor(sample: :development) {}
    end
  end

  context 'no options' do
    it 'calls #job_start and #job_end' do
      client = Jobmon::Client.new
      expect(client).to receive(:job_start).with('test', 3.minutes).once
      expect(client).to receive(:job_end).once
      SampleModule.client = client
      SampleModule.task_with_monitor(:sample) {}
    end
  end
end
