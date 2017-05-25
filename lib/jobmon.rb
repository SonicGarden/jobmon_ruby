require 'rails'
require 'faraday'
require 'faraday_middleware'

module Jobmon
end

require 'jobmon/version'
require 'jobmon/client'
require 'jobmon/railtie' if defined?(::Rails)
require 'jobmon/configure'
