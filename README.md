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

https://job-mon.sonicgarden.jp/apps で監視するアプリケーションを登録します。

登録したアプリケーションの情報をもとに、`config/initializers/jobmon.rb`を作成します。

```
## config/initializers/jobmon.rb
Jobmon.configure do |config|
  config.monitor_api_key = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
  config.error_handle    = -> (e) { Bugsnag.notify(e) }
end
```

Rakefile にて、'jobmon/rake_monitor' を読み込みます。

```
require 'jobmon/rake_monitor'
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

