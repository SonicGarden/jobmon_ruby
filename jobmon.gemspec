# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jobmon/version'

Gem::Specification.new do |spec|
  spec.name          = "jobmon"
  spec.version       = Jobmon::VERSION
  spec.authors       = [""]
  spec.email         = [""]

  spec.summary       = %q{Jobmon}
  spec.description   = %q{Jobmon}
  spec.homepage      = "https://github.com/SonicGarden/jobmon_ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'rake', '>= 0.8.7'

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
