require 'rails/generators'

class JobmonGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  desc 'Configures the jobmon'
  def create_initializer_file
    initializer 'jobmon.rb' do
      <<-EOF
Jobmon.configure do |config|
  config.monitor_email   = "support+#{fetch_app_name}@sonicgarden.jp"
  config.monitor_api_key = "#{fetch_api_key}"
end
      EOF
    end
  end

  def client
    @client ||= Jobmon::Client.new
  end

  private

  def fetch_api_key
    res = client.conn.post '/api/apps.json', app: { name: fetch_app_name }
    res.body['api_key']
  end

  def fetch_app_name
    File.basename(Rails.root)
  end
end
