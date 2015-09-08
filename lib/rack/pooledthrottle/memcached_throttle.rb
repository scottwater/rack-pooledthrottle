module Rack
  module PooledThrottle
    class MemcachedThrottle < Throttle
      def initialize(app, options={})
        super
      end

      def query_cache?(request)
          ((pool.with {|cache| cache.incr(cache_key(request), 1, ttl, 1)}) <= max)
      end      
    end
  end
end
