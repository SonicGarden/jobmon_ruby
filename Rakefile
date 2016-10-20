require "bundler/gem_tasks"
require "rspec/core/rake_task"

require 'jobmon'
require 'jobmon/rake_monitor'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require_relative 'config/initializers/jobmon'

task :environment do
end

task_with_monitor job: :environment, estimate_time: 100 do
  puts "execute"
end
