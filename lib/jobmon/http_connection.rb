# frozen_string_literal: true

require 'net/http'

module Jobmon
  class HttpConnection
    REQUEST_HEADERS = { 'Content-Type' => 'application/json; charset=utf-8' }.freeze
    NET_HTTP_EXCEPTIONS = [
      IOError,
      Errno::EADDRNOTAVAIL,
      Errno::EALREADY,
      Errno::ECONNABORTED,
      Errno::ECONNREFUSED,
      Errno::ECONNRESET,
      Errno::EHOSTUNREACH,
      Errno::EINVAL,
      Errno::ENETUNREACH,
      Errno::EPIPE,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      SocketError,
      Zlib::GzipFile::Error,
      OpenSSL::SSL::SSLError,
      Net::OpenTimeout,
    ].freeze

    def initialize(url:)
      uri = URI.parse(url)
      @http = Net::HTTP.new(uri.host, uri.port)
      @http.use_ssl = uri.scheme == 'https'
    end

    def post(url, body_hash)
      response = @http.post(url, body_hash.to_json, REQUEST_HEADERS)
      ResponseProxy.new(response)
    rescue *NET_HTTP_EXCEPTIONS => e
      raise ConnectionFailed, e
    end

    def put(url, body_hash)
      response = @http.put(url, body_hash.to_json, REQUEST_HEADERS)
      ResponseProxy.new(response)
    rescue *NET_HTTP_EXCEPTIONS => e
      raise ConnectionFailed, e
    end

    class Error < StandardError
    end

    class ConnectionFailed < Error
      def initialize(exception)
        @wrapped_exception = exception
        super "#{self.class.name}: #{exception.message}"
      end
    end

    class ResponseProxy
      def initialize(response)
        @response = response
      end

      def status
        @response.code.to_i
      end

      def body
        if @response.body.nil? || @response.body.empty?
          nil
        else
          @body_hash ||= JSON.parse(@response.body)
        end
      end
    end
  end
end
