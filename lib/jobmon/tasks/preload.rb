require 'jobmon/client'
require 'jobmon/rake_monitor'

config_file = Rails.root.join('config/initializers/jobmon.rb')
if File.exists?(config_file)
  require config_file
end
