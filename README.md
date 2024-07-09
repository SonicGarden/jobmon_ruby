# Jobmon

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jobmon', github: 'SonicGarden/jobmon_ruby'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jobmon

## Usage

JobmonWebで監視するアプリケーションを登録します。

以下のコマンドを実行します。

```
bin/rails g jobmon
```

作成された`config/initializers/jobmon.rb`に監視するアプリケーションの`api_key`を設定します。

以下の確認用のコマンドでJobmonWebのアプリケーション上で Jobs が登録されることを確認してください。

```
bundle exec jobmon --name test_job --cmd "echo test"
```

`jobmon` コマンド経由でタスクやコマンドを実行することで監視することができます。

```
jobmon --estimate-time 600 cron:sample_task
jobmon --estimate-time 600 --name sample --cmd "bin/rails runner scripts/sample.rb"
```

### ActiveJobExtensionの使い方

JobmonをActiveJobと組み合わせて使用することで、Railsアプリケーション内のジョブの実行を簡単に監視することができます。以下の手順に従って設定してください。

```ruby
class SampleJob < ApplicationJob
  include Jobmon::ActiveJobExtension

  # Optional
  jobmon_with(name: 'jobmonに表示される定期タスク名', estimate_time: 1.minute)

  def perform(*args)
    # 実行したい処理
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jobmon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
