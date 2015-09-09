module Rack
  module PooledThrottle
    class Throttle
      attr_reader :app, :options

      def initialize(app, options = {})
        @app, @options = app, options
      end

      def call(env)
        request = Rack::Request.new(env)
        allowed?(request) ? app.call(env) : rate_limit_exceeded(request)
      end

      protected
      
      def throttled_request?(request)
        if f = options[:throttled_request]
          f.call(request)
        else
          true
        end
      end

      def allowed?(request)
        if throttled_request?(request)
          case
            when whitelisted?(request) then true
            when blacklisted?(request) then false
            else
              query_cache?(request)
          end
        else
          true
        end
      end

      def query_cache?(request)
        false
      end

      def whitelisted?(request)
        if wl = options[:whitelisted]
          wl.call(request)
        else
          false
        end
      end

      def blacklisted?(request)
        if bl = options[:blacklisted]
          bl.call(request)
        else
          false
        end
      end

      def cache_key(request)
        "#{namespace}:#{key_prefix}#{client_identifier(request)}"
      end


      ##
      # @param  [Rack::Request] request
      # @return [String]
      def client_identifier(request)
        if cio = options[:client_identifier]
          cio.call(request)
        else
          request.ip.to_s
        end
      end

      def namespace
        options[:namespace] || 'rpt'
      end

      def key_prefix
        options[:key_prefix]
      end

      def pool
        options[:pool]
      end

      def max
        (options[:max] || 10).to_i
      end

      def ttl
        (options[:ttl] || 60).to_i
      end

      ##
      # Outputs a `Rate Limit Exceeded` error.
      #
      # @return [Array(Integer, Hash, #each)]
      def rate_limit_exceeded(request)
        options[:rate_limit_exceeded_callback].call(request) if options[:rate_limit_exceeded_callback]
        headers = respond_to?(:retry_after) ? {'Retry-After' => retry_after.to_f.ceil.to_s} : {}
        http_error(options[:code] || 403, options[:message] || 'Rate Limit Exceeded', headers)
      end

      ##
      # Outputs an HTTP `4xx` or `5xx` response.
      #
      # @param  [Integer]                code
      # @param  [String, #to_s]          message
      # @param  [Hash{String => String}] headers
      # @return [Array(Integer, Hash, #each)]
      def http_error(code, message = nil, headers = {})
        [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers),
          [http_status(code), (message.nil? ? "\n" : " (#{message})\n")]]
      end

      ##
      # Returns the standard HTTP status message for the given status `code`.
      #
      # @param  [Integer] code
      # @return [String]
      def http_status(code)
        [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ')
      end
      
    end
  end
end
