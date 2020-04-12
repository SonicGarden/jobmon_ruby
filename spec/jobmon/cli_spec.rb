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

    context '--estimate-time 100 --name hoge echo -n test' do
      let(:argv) { ['--estimate-time', '100', '--name', 'hoge', 'echo', '-n', 'test'] }

      it do
        expect(cli.options).to eq({
          estimate_time: 100,
          name: 'hoge',
        })
        expect(cli.cmd).to eq ['echo', '-n', 'test']
      end
    end

    context '--estimate-time=100 --name=hoge echo -n test' do
      let(:argv) { ['--estimate-time=100', '--name=hoge', 'echo', '-n', 'test'] }


      it do
        expect(cli.options).to eq({
          estimate_time: 100,
          name: 'hoge',
        })
        expect(cli.cmd).to eq ['echo', '-n', 'test']
      end
    end

    context '-t 100 -n hoge echo -n test' do
      let(:argv) { ['-t', '100', '-n', 'hoge', 'echo', '-n', 'test'] }

      it do
        expect(cli.options).to eq({
          estimate_time: 100,
          name: 'hoge',
        })
        expect(cli.cmd).to eq ['echo', '-n', 'test']
      end
    end
  end

  describe '#run' do
    let (:client) { Jobmon::Client.new }
    let(:cli) { Jobmon::CLI.new(argv) }

    before do
      allow(cli).to receive(:client).and_return(client)
    end

    context '-t 100 -n sample echo test' do
      let(:argv) { ['-t', '100', '-n', 'sample', 'echo', 'test'] }

      it 'calls Jobmon::Client#job_monitor' do
        expect(client).to receive(:job_monitor).with('sample', 100).once
        cli.run
      end

      it 'calls Kernel.system' do
        status = double('Status')
        allow(status).to receive(:exitstatus).and_return(0)
        allow(Process).to receive(:last_status).and_return(status)

        expect(Kernel).to receive(:system).with('echo', 'test').once
        expect(cli.run).to eq 0
      end
    end
  end
end
