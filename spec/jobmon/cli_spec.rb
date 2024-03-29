require 'spec_helper'
require 'jobmon/cli'

describe Jobmon::CLI do
  describe '#initialize' do
    let(:cli) { Jobmon::CLI.new(argv) }

    before do
      Jobmon.configure do |config|
        config.estimate_time = 3.minutes
      end
    end

    context '--estimate-time 100 --name hoge --cmd "echo -n test"' do
      let(:argv) { ['--estimate-time', '100', '--name', 'hoge', '--cmd', 'echo -n test'] }

      it do
        expect(cli.options).to eq({
          estimate_time: 100,
          name: 'hoge',
          cmd: 'echo -n test',
        })
      end
    end

    context '--estimate-time=100 --name=hoge hoge:task' do
      let(:argv) { ['--estimate-time=100', '--name=hoge', 'hoge:task'] }


      it do
        expect(cli.options).to eq({
          estimate_time: 100,
          name: 'hoge',
        })
        expect(cli.task_argv).to eq ['hoge:task']
      end
    end
  end

  describe '#run' do
    let(:client) { Jobmon::Client.new }
    let(:cli) { Jobmon::CLI.new(argv) }
    let(:api_base_url) { 'https://job-mon.sg-apps.com' }
    let(:start_api_url) { "#{api_base_url}/api/apps/test_key/jobs.json" }
    let(:finish_api_url) { "#{api_base_url}/api/apps/test_key/jobs/333/finished.json" }
    let(:stub_job_response_json) { { id: 333 }.to_json }

    before do
      allow(cli).to receive(:client).and_return(client)
      stub_request(:post, start_api_url)
        .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })
      stub_request(:put, "#{api_base_url}/api/apps/test_key/jobs/333/finished.json")
        .to_return(status: 200, body: stub_job_response_json, headers: { 'Content-Type': 'application/json' })
    end

    context '-e 100 -n sample -c "echo test"' do
      let(:argv) { ['-e', '100', '-n', 'sample', '-c', 'echo test'] }

      it 'calls Jobmon::Client#job_monitor' do
        expect(client).to receive(:job_monitor).with('sample', 100).once
        cli.run
      end

      it 'calls Kernel.system' do
        status = double('Status')
        allow(status).to receive(:exitstatus).and_return(0)
        allow(Process).to receive(:last_status).and_return(status)

        expect(Kernel).to receive(:system).with('echo test').once
        expect(cli.run).to eq 0
      end
    end

    context '--estimate-time 100 sample[arg1,arg2]' do
      let(:argv) { ['--estimate-time', '100', 'sample[arg1,arg2]'] }

      after do
        Rake::Task.clear
      end

      it 'calls Jobmon::Client#job_monitor' do
        expect(client).to receive(:job_monitor).with('sample', 100).once
        cli.run
      end

      it 'calls Rake::Task#invoke' do
        foo = nil
        bar = nil
        Rake::Task.define_task(:environment) {}
        task = Rake::Task.define_task(:sample, [:foo, :bar] => :environment) do |_ ,args|
          foo = args[:foo]
          bar = args[:bar]
        end

        expect(cli.run).to eq 0
        expect(foo).to eq 'arg1'
        expect(bar).to eq 'arg2'
      end
    end

    context '--estimate-time 100 sample foo=1 bar=2' do
      let(:argv) { ['--estimate-time', '100', 'sample', 'foo=1', 'bar=2'] }

      after do
        Rake::Task.clear
      end

      it 'calls Jobmon::Client#job_monitor' do
        expect(client).to receive(:job_monitor).with('sample', 100).once
        cli.run
      end

      it '環境変数がセットされること' do
        foo = nil
        bar = nil
        task = Rake::Task.define_task(:sample) do
          foo = ENV['foo']
          bar = ENV['bar']
        end

        expect(cli.run).to eq 0
        expect(foo).to eq '1'
        expect(bar).to eq '2'
      end
    end
  end
end
