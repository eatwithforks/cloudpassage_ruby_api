# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloudpassage/version'

Gem::Specification.new do |spec|
  spec.name          = "cloudpassage"
  spec.version       = Cloudpassage::VERSION
  spec.authors       = ["Jye Lee"]
  spec.email         = ["jlee@cloudpassage.com"]

  spec.summary       = %q{Ruby Cloudpassage API}
  spec.description   = %q{Ruby Cloudpassage API with GET POST PUT DELETE}
  spec.homepage      = "https://devgit.cloudpassage.com/jlee/ruby_api"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.

  spec.files         = ["lib/cloudpassage.rb", "lib/oauth.rb", "lib/validate.rb", "lib/paginate.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency('rest-client', '~> 1.6.7', '>= 1.6.7')
  spec.add_runtime_dependency('oauth', '>=0.5.1')
  spec.add_runtime_dependency('json', '>= 1.8.1')
  spec.add_runtime_dependency('parallel', '>= 1.9.0')
  spec.add_runtime_dependency('activesupport', '>=5.0.0.1')
  spec.add_runtime_dependency('bundler', '>=1.14')

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
