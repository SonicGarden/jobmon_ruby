# Jobmon

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jobmon', git: 'https://github.com/SonicGarden/jobmon_ruby.git'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jobmon

## Usage

https://job-mon.sg-apps.com で監視するアプリケーションを登録します。

以下のコマンドを実行します。

```
bin/rails g jobmon
```

作成された`config/initializers/jobmon.rb`に監視するアプリケーションの`api_key`を設定します。

以下の確認用のコマンドで https://job-mon.sg-apps.com のアプリケーション上で Jobs が登録されることを確認してください。

```
bundle exec jobmon --name test_job echo test
```

`jobmon` コマンド経由でタスクを実行することで、 task を監視することができます。

```
jobmon --estimate-time 600 --name job bin/rake job
```

In `config/schedule.rb`:

```ruby
set :path, File.realpath('../', __dir__)
set :output, "#{path}/log/batch.log"
set :estimate_time, 180

job_type :jobmon, 'cd :path && bundle exec jobmon --name :task --estimate-time :estimate_time bin/rake :task :output'

every 10.minutes do
  jobmon 'cron:hoge_task'
end

every 1.day, at: '00:00' do
  jobmon 'cron:heavy_task', estimate_time: 600
end
```

また以下のようにタスク定義すると `jobmon` ブロック内の全てのタスクが監視されます。（非推奨）

```ruby
jobmon estimate_time: 10.minutes do
  task job: :environment do
    puts "execute"
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jobmon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
