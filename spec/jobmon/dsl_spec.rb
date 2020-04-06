require 'spec_helper'
require 'jobmon/dsl'
require 'jobmon/task'

describe Jobmon::DSL do
  class SampleApp
    include Rake::DSL
    include Jobmon::DSL
  end

  let (:app) { SampleApp.new }

  describe '#task_with_monitor' do
    context 'sample: :environment, estimate_time: 10.minutes' do
      it 'task定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 10.minutes, skip_jobmon_available_check: false }, [{ sample: :environment }]).once
        app.instance_exec do
          task_with_monitor sample: :environment, estimate_time: 10.minutes {}
        end
      end
    end

    context ':sample, [:arg1, :arg2] => :environment, estimate_time: 10.minutes' do
      it 'task定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 10.minutes, skip_jobmon_available_check: false }, [:sample, { [:arg1, :arg2] => :environment }]).once
        app.instance_exec do
          task_with_monitor :sample, [:arg1, :arg2] => :environment, estimate_time: 10.minutes {}
        end
      end
    end

    context ':sample, estimate_time: 10.minutes' do
      it 'task定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 10.minutes, skip_jobmon_available_check: false }, [:sample, {}]).once
        app.instance_exec do
          task_with_monitor :sample, estimate_time: 10.minutes do
          end
        end
      end
    end

    context ':sample' do
      it 'デフォルトオプションによりtask定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 3.minutes, skip_jobmon_available_check: false }, [:sample]).once
        app.instance_exec do
          task_with_monitor :sample do
          end
        end
      end
    end
  end

  describe '#jobmon' do
    context 'without jobmon' do
      it '通常のRake Taskが定義されること' do
        expect(Rake::Task).to receive(:define_task).with(:sample).once
        app.instance_exec do
          task :sample do
          end
        end
      end
    end

    context 'jobmon' do
      it 'デフォルトオプションによりtask定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 3.minutes, skip_jobmon_available_check: false }, [:sample]).once
        app.instance_exec do
          jobmon do
            task :sample do
            end
          end
        end
      end
    end

    context 'jobmon estimate_time: 10.minutes' do
      it '指定オプションによりtask定義されること' do
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 10.minutes, skip_jobmon_available_check: false }, [:sample]).once
        expect(Jobmon::Task).to receive(:define_task).with({ estimate_time: 10.minutes, skip_jobmon_available_check: false }, [:hoge]).once
        app.instance_exec do
          jobmon estimate_time: 10.minutes do
            task :sample do
            end
            task :hoge do
            end
          end
        end
      end
    end
  end
end
