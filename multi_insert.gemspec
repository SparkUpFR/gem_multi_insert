# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'multi_insert/version'

Gem::Specification.new do |spec|
  spec.name          = "multi_insert"
  spec.version       = MultiInsert::VERSION
  spec.authors       = ["Nax"]
  spec.email         = ["max@bacoux.com"]

  spec.summary       = %q{Simple additions to write efficient insert queries.}
  spec.homepage      = "https://github.com/SparkUpFR/gem_multi_insert"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  spec.add_runtime_dependency "activerecord", ">= 4.0"
end
