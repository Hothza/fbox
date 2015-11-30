# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fbox/version'

Gem::Specification.new do |spec|
  spec.name          = "fbox"
  spec.version       = Fbox::VERSION
  spec.authors       = ["Hothza"]
  spec.email         = ["hothza@gmx.com"]

#  if spec.respond_to?(:metadata)
#    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
#  end

  spec.summary       = %q{Fbox - FaucetBox REST API helper. It allows you to integrate FaucetBox API in an easy way in your RubyOnRails application. }
  spec.homepage      = "https://github.com/Hothza/fbox"
  spec.license       = "BSD"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_dependency "minitest"
  spec.add_dependency "coins_address_validator"
end
