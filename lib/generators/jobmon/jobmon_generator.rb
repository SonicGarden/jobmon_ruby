require 'rails/generators'

class JobmonGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc 'Configures the jobmon'
  def create_initializer_file
    initializer 'jobmon.rb' do
      <<~EOF
        Jobmon.configure do |config|
          config.monitor_api_key = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxx"
          config.error_handle = -> (e) { Bugsnag.notify(e) }
          config.available_release_stages = %w[staging production]
          config.estimate_time = 3.minutes
          config.logger = Rails.logger
        end
      EOF
    end
  end
end
