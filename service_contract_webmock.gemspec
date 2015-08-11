# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_contract_webmock/version'

Gem::Specification.new do |spec|
  spec.name          = "service_contract_webmock"
  spec.version       = ServiceContractWebmock::VERSION
  spec.authors       = ["Donald Plummer"]
  spec.email         = ["donald.plummer@gmail.com"]

  spec.summary       = %q{A library for generating webmock mocks with ServiceContract schemas}
  spec.homepage      = "https://github.com/dplummer/service_contract_webmock"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "avro"
  spec.add_dependency "service_contract"
  spec.add_dependency "webmock"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
