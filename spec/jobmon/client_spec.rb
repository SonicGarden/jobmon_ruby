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
    before do
      Jobmon.configure do |config|
        config.error_handle = -> (e) do
          expect(e).to be_a Jobmon::RequestError
          expect(e.message).to eq 'test error'
        end
      end
    end

    after do
      Jobmon.configure do |config|
        config.error_handle = -> (e) {}
      end
    end

    context '開始時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        stubs.post('/api/apps/test_key/jobs.json') do
          raise Faraday::ConnectionFailed, 'test error'
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
          raise Faraday::ConnectionFailed, 'test error'
        end

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control
        stubs.verify_stubbed_calls
      end
    end
  end

  describe '#job_start' do
    before do
      Jobmon.configure do |config|
        config.hostname = 'dummyhost'
      end
    end

    it do
      stubs.post('/api/apps/test_key/jobs.json') do |env|
        params = JSON.parse(env.request_body)
        expect(params['job']['hostname']).to eq 'dummyhost'

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
    before do
      allow(Jobmon.configuration.error_handle).to receive(:call)
    end

    it 'エラーハンドラが呼ばれないこと' do
      stubs.put('/api/apps/test_key/jobs/333/finished.json') do |env|
        expect(env.request_body).to eq "{\"job\":{\"rails_env\":\"development\"}}"
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"id": 333}'
        ]
      end
      job_mon.job_end(333)
      expect(Jobmon.configuration.error_handle).not_to have_received(:call)
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
