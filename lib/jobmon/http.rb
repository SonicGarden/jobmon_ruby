require 'net/http'

module Jobmon
  class Http
    class << self
      def json(endpoint)
        default_headers = {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
        new(endpoint, default_headers)
      end
    end

    def initialize(endpoint, default_headers = {})
      @endpoint_uri = URI(endpoint)
      @default_headers = default_headers
    end

    def post(path, body)
      req = initialize_request(Net::HTTP::Post.new(path), body)
      net_http.request(req)
    end

    def put(path, body)
      req = initialize_request(Net::HTTP::Put.new(path), body)
      net_http.request(req)
    end

    private

    def net_http
      http = Net::HTTP.new(@endpoint_uri.hostname, @endpoint_uri.port)
      http.use_ssl = @endpoint_uri.scheme == 'https'
      http
    end

    def initialize_request(request, body)
      @default_headers.each do |k, v|
        request.add_field(k, v)
      end
      request.body = body
      request
    end
  end
end
