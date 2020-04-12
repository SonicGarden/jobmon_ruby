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
end
