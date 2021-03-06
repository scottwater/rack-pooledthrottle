# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/pooledthrottle/version'

Gem::Specification.new do |spec|
  spec.name          = "rack-pooledthrottle"
  spec.version       = Rack::Pooledthrottle::VERSION
  spec.authors       = ["Scott Watermasysk"]
  spec.email         = ["scottwater@gmail.com"]
  spec.summary       = %q{Throttle HTTP requests.}
  spec.description   = %q{Throttle HTTP requests using a connection pool for all database connections}
  spec.homepage      = ""
  spec.license       = "Public Domain"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency     'rack',      '~> 1'
  spec.add_runtime_dependency     'connection_pool', "~> 2.2"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.3"
  spec.add_development_dependency 'rack-test', '0.6.3'
  spec.add_development_dependency 'dalli', '~> 2.7'
  
end
