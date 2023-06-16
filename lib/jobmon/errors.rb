module Jobmon
  class RequestError < StandardError
    attr_reader :original

    def initialize(error)
      @original = error
      super(error.message)
    end
  end

  class TaskJobError < StandardError
  end
end
