module Jobmon
  def self.configure(&block)
    @configure ||= Configure.new
    yield @configure if block_given?
    @configure
  end

  def self.available?
    configure.available_release_stagings.include?(Rails.env)
  end

  class Configure
    attr_accessor :monitor_email, :monitor_api_key, :error_handle, :available_release_stagings
    def initialize
      @error_handle = -> (e) {}
      @available_release_stagings = %w[staging production]
    end
  end
end
