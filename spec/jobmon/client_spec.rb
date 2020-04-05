require 'spec_helper'
require 'ostruct'

describe Jobmon::Client do
  let(:job_mon) { Jobmon::Client.new }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) do
    Faraday.new do |b|
      b.request  :json
      b.response :json
      b.adapter :test, stubs
    end
  end

  before do
    allow(job_mon).to receive(:conn).and_return(conn)
  end

  describe '#job_monitor' do
    Jobmon.configure do |config|
      config.error_handle = -> (e) {}
    end

    context '開始時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        stubs.post('/api/apps/test_key/jobs.json') do
          raise Faraday::ConnectionFailed, nil
        end

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control
        stubs.verify_stubbed_calls
      end
    end

    context '終了時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        stubs.post('/api/apps/test_key/jobs.json') do |env|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"id": 333}'
          ]
        end
        stubs.put('/api/apps/test_key/jobs/333/finished.json') do |env|
          raise Faraday::ConnectionFailed, nil
        end

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#job_start' do
    it do
      stubs.post('/api/apps/test_key/jobs.json') do |env|
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"id": 333}'
        ]
      end
      expect(job_mon.job_start('task', 10)).to eq 333
      stubs.verify_stubbed_calls
    end
  end

  describe '#job_end' do
    it do
      stubs.put('/api/apps/test_key/jobs/333/finished.json') do |env|
        expect(env.request_body).to eq "{\"job\":{\"rails_env\":\"development\"}}"
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"id": 333}'
        ]
      end
      expect(job_mon.job_end(333)).to eq 333
    end
  end

  describe '#send_queue_log' do
    it do
      stubs.post('/api/apps/test_key/queue_logs.json') do |env|
        expect(env.request_body).to eq "{\"queue_log\":{\"count\":10,\"rails_env\":\"development\"}}"
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"id": 333}'
        ]
      end
      expect(job_mon.send_queue_log(10)).to eq 333
    end
  end
end
