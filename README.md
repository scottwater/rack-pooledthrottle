# Rack::Pooledthrottle

Rack::Pooledthrottle is middleware which provides rate-limiting of incoming HTTP requests to Rack applications. You should be able to use it with any Ruby web framework (I have only tested Sinatra and Rails). 

I initially tried to work it into  [Rack Throttle](https://github.com/bendiken/rack-throttle), but because of Rack Throttle's 
many backend options I thought it would be too complicated. 

So how is it different? 

1. It uses a pool (via [ConnectionPool](https://github.com/mperham/connection_pool)) of connections instead of creating one on each request 
1. It uses a sliding TTL for tracking. This means if you limit an IP to 10 requests every hour and the first request comes in at 1:30 the user can make up to 9 more requests until 2:30.
1. The TTL is set on middleware declaration. No other subclasses. 
1. Database support is limited to Memcached (and eventually Redis)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-pooledthrottle'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-pooledthrottle

## Usage

### Adding throttling to a Rails application

    require 'rack/pooledthrottle'
    require 'dalli' #Dalli is not required. You must add it to your gem file if you want to use it. 
    $mc_pool ||= ConnectionPool.new(size: 5) {Dalli::Client.new}
    
    class Application < Rails::Application
      config.middleware.use Rack::PooledThrottle::MemcachedThrottle, max: 10, ttl: 3600, pool: $mc_pool
    end    
    
### Adding throttling to a Sinatra application

    require 'sinatra'
    require 'rack/pooledthrottle'
    
    use Rack::PooledThrottle::MemcachedThrottle, max: 5, ttl: 60, pool: $mc_pool #see above for pool
    
    get('/hello') { "Hello, world!\n" }    

## HAT TIP 

I just want to make it super clear that a vast majority of this code was based on the excellent work of [Rack Throttle](https://github.com/bendiken/rack-throttle).


## Contributing

1. Fork it ( https://github.com/[my-github-username]/rack-pooledthrottle/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
