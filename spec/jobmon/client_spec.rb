require 'spec_helper'
require 'ostruct'

class Jobmon::DummyLogger
  attr_reader :stream

  def initialize
    @stream = []
  end

  def warn(text)
    @stream << [:warn, text]
  end

  def info(text)
    @stream << [:info, text]
  end
end

describe Jobmon::Client do
  let(:job_mon) { Jobmon::Client.new }
  let(:api_base_url) { 'https://job-mon.sg-apps.com' }
  let(:start_api_url) { "#{api_base_url}/api/apps/test_key/jobs.json" }
  let(:finish_api_url) { "#{api_base_url}/api/apps/test_key/jobs/333/finished.json" }
  let(:stub_job_response_json) { { id: 333 }.to_json }

  describe '#job_monitor' do
    before do
      Jobmon.configure do |config|
        config.error_handle = -> (e) do
          error_container << e
        end
        config.logger = Jobmon::DummyLogger.new
      end
    end

    after do
      Jobmon.configure do |config|
        config.error_handle = -> (e) {}
        config.logger = Rails.logger
      end
    end

    let(:error_container) { [] }

    context '開始時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        stub_request(:post, start_api_url)
          .to_raise(Net::OpenTimeout)

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control

        error = error_container.last
        expect(error).to be_a Jobmon::RequestError
        expect(error.message).to start_with 'Jobmon::HttpConnection::ConnectionFailed'

        expect(Jobmon.configuration.logger.stream).to include [:warn, '[Jobmon] Failed to send job_start task']
      end
    end

    context '実行時にエラー' do
      it 'ジョブ実行時にエラー発生すると、失敗しログに残ること' do
        stub_request(:post, start_api_url)
          .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })
        stub_request(:put, "#{api_base_url}/api/apps/test_key/jobs/333/finished.json")
          .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })

        expected = expect do
          job_mon.job_monitor('task', 10) do
            raise 'Failed to execute job'
          end
        end
        expected.to raise_error(RuntimeError, 'Failed to execute job')

        expect(Jobmon.configuration.logger.stream).to eq [
          [:info, "[Jobmon] before job_start task"],
          [:info, "[Jobmon] Sending job_start request for task"],
          [:info, "[Jobmon] Received response for job_start request for task, status: 200"],
          [:info, "[Jobmon] after job_start task"],
          [:warn, "[Jobmon] Failed job task"],
          [:info, '[Jobmon] before job_end task'],
          [:info, "[Jobmon] Sending job_end request for task"],
          [:info, "[Jobmon] Received response for job_end request for task, status: 200"],
          [:info, '[Jobmon] after job_end task'],
        ]

        expect(WebMock).to have_requested(:post, start_api_url)
        expect(WebMock).to have_requested(:put, finish_api_url)
      end
    end

    context '終了時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        stub_request(:post, start_api_url)
          .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })
        stub_request(:put, finish_api_url)
          .to_raise(Net::OpenTimeout)

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control

        error = error_container.last
        expect(error).to be_a Jobmon::RequestError
        expect(error.message).to start_with 'Jobmon::HttpConnection::ConnectionFailed'

        expect(Jobmon.configuration.logger.stream).to include [:warn, '[Jobmon] Failed to send job_end task']

        expect(WebMock).to have_requested(:post, start_api_url)
        expect(WebMock).to have_requested(:put, finish_api_url).times(3)
      end
    end

    context '正常に実行および送信できたとき' do
      it 'タスクが実行されサーバへ開始、終了通知が送信される' do
        stub_request(:post, start_api_url)
          .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })
        stub_request(:put, "#{api_base_url}/api/apps/test_key/jobs/333/finished.json")
          .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })

        result = job_mon.job_monitor('task', 10) do
          'result'
        end
        expect(result).to eq('result')

        expect(Jobmon.configuration.logger.stream).to eq [
          [:info, '[Jobmon] before job_start task'],
          [:info, "[Jobmon] Sending job_start request for task"],
          [:info, "[Jobmon] Received response for job_start request for task, status: 200"],
          [:info, '[Jobmon] after job_start task'],
          [:info, '[Jobmon] before job_end task'],
          [:info, "[Jobmon] Sending job_end request for task"],
          [:info, "[Jobmon] Received response for job_end request for task, status: 200"],
          [:info, '[Jobmon] after job_end task'],
        ]

        expect(WebMock).to have_requested(:post, start_api_url)
        expect(WebMock).to have_requested(:put, finish_api_url)
      end
    end

    context 'Jobmon.available?がfalseの場合', no_jobmon_mock: true do
      before do
        allow(Jobmon).to receive(:available?).and_return(false)
        allow(job_mon).to receive(:job_start)
        allow(job_mon).to receive(:job_end)
      end

      it 'job_startとjob_endが呼ばれないこと' do
        result = job_mon.job_monitor('task', 10) { 'result' }
        expect(result).to eq('result')
        expect(job_mon).not_to have_received(:job_start)
        expect(job_mon).not_to have_received(:job_end)
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
      stub_request(:post, start_api_url)
        .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })

      expect(job_mon.job_start('task', 10)).to eq 333

      expect(WebMock).to have_requested(:post, start_api_url).
        with { |req| JSON.parse(req.body)['job']['hostname'] == 'dummyhost' }
    end
  end

  describe '#job_end' do
    before do
      allow(Jobmon.configuration.error_handle).to receive(:call)
    end

    it 'エラーハンドラが呼ばれないこと' do
      # NOTE: テスト実行環境のタイムゾーンに影響受けないように
      Time.use_zone('Tokyo') do
        travel_to('2021-03-23 07:28:48 +0900') do
          stub_request(:put, finish_api_url)
            .with(body: "{\"job\":{\"rails_env\":\"development\",\"end_at\":\"2021-03-23T07:28:48.000+09:00\"}}")
            .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })

          job_mon.job_end('test', 333)
          expect(Jobmon.configuration.error_handle).not_to have_received(:call)

          expect(WebMock).to have_requested(:put, finish_api_url)
        end
      end
    end
  end

  describe '#send_queue_log' do
    let(:queue_api_url) { "#{api_base_url}/api/apps/test_key/queue_logs.json" }

    it do
      stub_request(:post, queue_api_url)
        .with(body: "{\"queue_log\":{\"count\":10,\"rails_env\":\"development\"}}")
        .to_return(status: 200, body: { id: 333 }.to_json, headers: { 'Content-Type': 'application/json' })

      expect(job_mon.send_queue_log(10)).to eq 333

      expect(WebMock).to have_requested(:post, queue_api_url)
    end
  end
end
