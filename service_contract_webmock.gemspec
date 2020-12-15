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
  spec.homepage      = "https://github.com/avvo/service_contract_webmock"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://avvo-gems.public.artifactory.internetbrands.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "avro"
  spec.add_dependency "service_contract"
  spec.add_dependency "webmock"
  spec.add_dependency "rack", ">= 2.1.4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec"
end
