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

https://job-mon.sg-apps.com で監視するアプリケーションを登録します。

以下のコマンドを実行します。

```
bin/rails g jobmon
```

作成された`config/initializers/jobmon.rb`に監視するアプリケーションの`api_key`を設定します。

以下の確認用の task で https://job-mon.sg-apps.com のアプリケーション上で Jobs が登録されることを確認してください。

```
bundle exec rake jobmon:test_job
```

rake で、`task_with_monitor` を使ってタスクを記述することで、 task を監視することができます。

```
task_with_monitor job: :environment, estimate_time: 10 do
  puts "execute"
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/jobmon. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
