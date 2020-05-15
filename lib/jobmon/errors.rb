module Jobmon
  class ConnectionError < StandardError
    attr_reader :original

    def initialize(error)
      @original = error
      super(error.message)
    end
  end
end
