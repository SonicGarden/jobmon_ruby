require 'spec_helper'
require 'jobmon/task'

describe Jobmon::Task do
  let (:client) { Jobmon::Client.new }
  let(:options) do
    { estimate_time: 10.minutes }
  end
  let!(:environment_task) { Rake::Task.define_task(:environment) {} }

  before do
    allow(Jobmon::Task).to receive(:client).and_return(client)
  end

  after do
    Rake::Task.clear
  end

  describe '.define_task' do
    context 'without error' do
      let(:args) do
        [{ sample: :environment }]
      end
      it 'calls #job_start and #job_end' do
        expect(client).to receive(:job_start).with('sample', 10.minutes).once
        expect(client).to receive(:job_end).once
        expect(environment_task).to receive(:execute).once
        task = Jobmon::Task.define_task(options, args) {}
        task.invoke
      end
    end

    context 'with error' do
      let(:args) do
        [{ sample: :environment }]
      end

      it 'calls #job_start and #job_end and raise error' do
        expect(client).to receive(:job_start).once
        expect(client).to receive(:job_end).once
        expect {
          task = Jobmon::Task.define_task(options, args) { raise 'test' }
          task.invoke
        }.to raise_error(RuntimeError, 'test')
      end
    end

    context 'with task args' do
      let(:args) do
        [:sample, { [:arg1, :arg2] => :environment }]
      end

      it 'calls #job_start and #job_end' do
        expect(client).to receive(:job_start).with('sample', 10.minutes).once
        expect(client).to receive(:job_end).once
        task = Jobmon::Task.define_task(options, args) {}
        task.invoke
      end
    end

    context 'no task args' do
      let(:args) { [:sample] }

      it 'calls #job_start and #job_end' do
        expect(client).to receive(:job_start).with('sample', 10.minutes).once
        expect(client).to receive(:job_end).once
        task = Jobmon::Task.define_task(options, args) {}
        task.invoke
      end
    end
  end
end
