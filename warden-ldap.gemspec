# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warden/ldap/version'

Gem::Specification.new do |spec|
  spec.name          = "warden-ldap"
  spec.version       = Warden::Ldap::VERSION
  spec.authors       = ["Maher Hawash"]
  spec.email         = ["gmhawash@gmail.com"]
  spec.description   = %q{Provides ldap strategy for warden}
  spec.summary       = %q{Provides ldap strategy for wrden}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_runtime_dependency "warden", '~> 1.2.1'
  spec.add_runtime_dependency "net-ldap", '~> 0.3.1'
end
