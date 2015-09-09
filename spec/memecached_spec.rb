require 'spec_helper'
require 'dalli'

describe Rack::PooledThrottle::MemcachedThrottle do 
  include Rack::Test::Methods
  
  before(:each) do 
    pool.with{|m| m.flush}
    @options = {
      pool: pool, 
      max: 3,
      ttl: 30
    }
  end
  
  def pool 
    @pool ||= ConnectionPool.new(size: 1) do 
      Dalli::Client.new((ENV["MEMCACHED_SERVERS"] || "127.0.0.1:11211").split(",").map{|s| s.strip})
    end
  end
  
  def app 
    @app ||= Rack::PooledThrottle::MemcachedThrottle.new(example_target_app, @options)
  end
  
  it 'expect a passing message' do 
    get '/foo'
    expect(last_response.body).to show_allowed_response
  end
  
  it 'expect a passing message' do 
    4.times {get '/foo'}
    expect(last_response.body).to show_throttled_response
  end
  
  it "should return true if whitelisted" do
    allow(app).to receive(:whitelisted?).and_return(true)
    4.times {get "/foo"}
    expect(last_response.body).to show_allowed_response
  end
  
  it "should return true if blacklisted" do
    allow(app).to receive(:blacklisted?).and_return(true)
    get "/foo"
    expect(last_response.body).to show_throttled_response
  end
  

  
  
  it 'should allow the client_identifier to be overridden and pass' do 
    @options[:max] = 2
    @options[:client_identifier] = ->(request){request.params['email']}
    2.times {get('/foo', email: 'scottwater@gmail.com')}
    2.times {get '/foo', email: 'scott@kickofflabs.com'}
    expect(last_response.body).to show_allowed_response
  end

  it 'should allow the client_identifier to be overridden and fail' do 
    @options[:max] = 2
    @options[:client_identifier] = ->(request){request.params['email']}
    2.times {get('/foo', email: 'scottwater@gmail.com')}
    3.times {get '/foo', email: 'scott@kickofflabs.com'}
    expect(last_response.body).to show_throttled_response
  end
    
end
