# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubytus/version'

Gem::Specification.new do |spec|
  spec.name          = "rubytus"
  spec.version       = Rubytus::VERSION
  spec.authors       = ["Alif Rachmawadi"]
  spec.email         = ["subosito@gmail.com"]
  spec.description   = %q{Resumable upload protocol implementation in Ruby}
  spec.summary       = %q{Resumable upload protocol implementation in Ruby}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rr"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "em-http-request"

  spec.add_runtime_dependency "pry"
  # spec.add_runtime_dependency "goliath"
end
