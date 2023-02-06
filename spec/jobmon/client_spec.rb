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

class Jobmon::DummyHttp
  Response = Struct.new(:code, :body)

  def initialize
    @stubs = {}
  end

  def stub_post(path, &block)
    stub('post', path, &block)
  end

  def stub_put(path, &block)
    stub('put', path, &block)
  end

  def post(path, body)
    call_stub('post', path, body)
  end

  def put(path, body)
    call_stub('put', path, body)
  end

  def stub(method, path, &block)
    @stubs["#{method}_#{path}"] = { block: block, count: 0 }
  end

  def call_stub(method, path, req_body)
    stub = @stubs["#{method}_#{path}"]
    stub[:count] += 1
    status, _, body = stub[:block].call(req_body)

    Response.new(status.to_s, body)
  end

  def verify_stubbed_calls
    @stubs.values.all? { |stub| stub[:count] > 0 }
  end
end

describe Jobmon::Client do
  let(:job_mon) { Jobmon::Client.new }
  let(:conn) { Jobmon::DummyHttp.new }

  before do
    allow(job_mon).to receive(:conn).and_return(conn)
  end

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
        conn.stub_post '/api/apps/test_key/jobs.json' do
          raise SocketError, 'test error'
        end

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control
        conn.verify_stubbed_calls

        error = error_container.last
        expect(error).to be_a Jobmon::RequestError
        expect(error.message).to eq 'test error'

        expect(Jobmon.configuration.logger.stream).to include [:warn, '[Jobmon] Failed to send job_start task']
      end
    end

    context '実行時にエラー' do
      it 'ジョブ実行時にエラー発生すると、失敗しログに残ること' do
        conn.stub_post('/api/apps/test_key/jobs.json') do |body|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"id": 333}'
          ]
        end
        conn.stub_put('/api/apps/test_key/jobs/333/finished.json') do |req_body|
          [
            200,
            { 'Content-Type': 'application/json' },
          ]
        end

        expected = expect do
          job_mon.job_monitor('task', 10) do
            raise 'Failed to execute job'
          end
        end
        expected.to raise_error(RuntimeError, 'Failed to execute job')

        expect(Jobmon.configuration.logger.stream).to eq [
          [:info, "[Jobmon] before job_start task"],
          [:info, "[Jobmon] after job_start task"],
          [:warn, "[Jobmon] Failed job task"],
          [:info, '[Jobmon] before job_end task'],
          [:info, '[Jobmon] after job_end task'],
        ]
      end
    end

    context '終了時に接続エラー' do
      it 'jobmon接続時にエラー発生してもブロックは実行されること' do
        conn.stub_post('/api/apps/test_key/jobs.json') do |req_body|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"id": 333}'
          ]
        end
        conn.stub_put('/api/apps/test_key/jobs/333/finished.json') do |req_body|
          raise SocketError, 'test error'
        end

        expect { |b| job_mon.job_monitor('task', 10, &b) }.to yield_control
        conn.verify_stubbed_calls

        error = error_container.last
        expect(error).to be_a Jobmon::RequestError
        expect(error.message).to eq 'test error'

        expect(Jobmon.configuration.logger.stream).to include [:warn, '[Jobmon] Failed to send job_end task']
      end
    end

    context '正常に実行および送信できたとき' do
      it 'タスクが実行されサーバへ開始、終了通知が送信される' do
        conn.stub_post('/api/apps/test_key/jobs.json') do |req_body|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"id": 333}'
          ]
        end
        conn.stub_put('/api/apps/test_key/jobs/333/finished.json') do |req_body|
          [
            200,
            { 'Content-Type': 'application/json' },
            '{"id": 333}'
          ]
        end

        result = job_mon.job_monitor('task', 10) do
          'result'
        end
        expect(result).to eq('result')

        expect(Jobmon.configuration.logger.stream).to eq [
          [:info, '[Jobmon] before job_start task'],
          [:info, '[Jobmon] after job_start task'],
          [:info, '[Jobmon] before job_end task'],
          [:info, '[Jobmon] after job_end task'],
        ]
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
      conn.stub_post('/api/apps/test_key/jobs.json') do |req_body|
        expect(JSON.parse(req_body)['job']['hostname']).to eq 'dummyhost'

        [
          200,
          { 'Content-Type': 'application/json' },
          '{"id": 333}'
        ]
      end
      expect(job_mon.job_start('task', 10)).to eq 333
      conn.verify_stubbed_calls
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
          conn.stub_put('/api/apps/test_key/jobs/333/finished.json') do |req_body|
            expect(req_body).to eq "{\"job\":{\"rails_env\":\"development\",\"end_at\":\"2021-03-23 07:28:48 +0900\"}}"
            [
              200,
              { 'Content-Type': 'application/json' },
              '{"id": 333}'
            ]
          end
          job_mon.job_end('test', 333)
          expect(Jobmon.configuration.error_handle).not_to have_received(:call)
        end
      end
    end
  end

  describe '#send_queue_log' do
    it do
      conn.stub_post('/api/apps/test_key/queue_logs.json') do |req_body|
        expect(req_body).to eq "{\"queue_log\":{\"count\":10,\"rails_env\":\"development\"}}"
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
