require 'spec_helper'

describe Jobmon::QueueCount do
  describe '.call' do
    context 'アダプタがdelayed_jobのとき' do
      before do
        allow(Jobmon::QueueCount).to receive(:adapter_name).and_return('delayed_job')
        allow(Jobmon::QueueCount).to receive(:delayed_job).and_return(1)
      end

      it 'delayed_jobのカウントを返すこと' do
        expect(Jobmon::QueueCount.call).to eq 1
      end
    end

    context 'アダプタがgood_jobのとき' do
      before do
        allow(Jobmon::QueueCount).to receive(:adapter_name).and_return('good_job')
        allow(Jobmon::QueueCount).to receive(:good_job).and_return(2)
      end

      it 'good_jobのカウントを返すこと' do
        expect(Jobmon::QueueCount.call).to eq 2
      end
    end

    context 'アダプタがsidekiqのとき' do
      before do
        allow(Jobmon::QueueCount).to receive(:adapter_name).and_return('sidekiq')
        allow(Jobmon::QueueCount).to receive(:sidekiq).and_return(3)
      end

      it 'sidekiqのカウントを返すこと' do
        expect(Jobmon::QueueCount.call).to eq 3
      end
    end

    context 'アダプタがsolid_queueのとき' do
      before do
        allow(Jobmon::QueueCount).to receive(:adapter_name).and_return('solid_queue')
        allow(Jobmon::QueueCount).to receive(:solid_queue).and_return(4)
      end

      it 'solid_queueのカウントを返すこと' do
        expect(Jobmon::QueueCount.call).to eq 4
      end
    end

    context '未対応のアダプタのとき' do
      before do
        allow(Jobmon::QueueCount).to receive(:adapter_name).and_return('async')
      end

      it 'UnsupportedAdapterErrorを投げること' do
        expect { Jobmon::QueueCount.call }.to raise_error(Jobmon::UnsupportedAdapterError, "jobmon: unsupported queue adapter 'async'")
      end
    end
  end

  describe '.delayed_job' do
    it 'Delayed::Jobの実行遅延件数(失敗済みを除く)を返すこと' do
      delayed_job_class = Class.new do
        def self.where(*)
          self
        end

        def self.count
          5
        end
      end
      stub_const('Delayed::Job', delayed_job_class)

      expect(Jobmon::QueueCount.delayed_job).to eq 5
    end
  end

  describe '.good_job' do
    it 'GoodJob::Jobのqueued件数を返すこと' do
      good_job_class = Class.new do
        def self.queued
          self
        end

        def self.count
          6
        end
      end
      stub_const('GoodJob::Job', good_job_class)

      expect(Jobmon::QueueCount.good_job).to eq 6
    end
  end

  describe '.solid_queue' do
    it 'SolidQueue::ReadyExecutionの件数を返すこと' do
      solid_queue_class = Class.new do
        def self.count
          7
        end
      end
      stub_const('SolidQueue::ReadyExecution', solid_queue_class)

      expect(Jobmon::QueueCount.solid_queue).to eq 7
    end
  end

  describe '.adapter_name' do
    it 'ActiveJob::Base.queue_adapter_nameを文字列で返すこと' do
      active_job_base = Class.new do
        def self.queue_adapter_name
          :sidekiq
        end
      end
      stub_const('ActiveJob::Base', active_job_base)

      expect(Jobmon::QueueCount.adapter_name).to eq 'sidekiq'
    end
  end
end
