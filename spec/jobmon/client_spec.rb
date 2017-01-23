require 'spec_helper'
require 'ostruct'

TaskDefine = Struct.new(:name)

describe Jobmon::Client do
  let(:job_mon) { Jobmon::Client.new }
  let(:task) { TaskDefine.new('task') }

  context '#job_start' do
    it { expect(job_mon.job_start(task, 10, 'email@example.com')).not_to be_nil }
  end

  context '#job_end' do
    let!(:job_id) { job_mon.job_start(task, 10, 'email@example.com') }

    it { expect(job_mon.job_end(job_id)).not_to be_nil }
  end

  context '#send_queue_log' do
    it { expect(job_mon.send_queue_log(10)).not_to be_nil }
  end
end
