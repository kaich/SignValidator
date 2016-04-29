# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'SignValidator/version'

Gem::Specification.new do |spec|
  spec.name          = "SignValidator"
  spec.version       = SignValidator::VERSION
  spec.authors       = ["kaich"]
  spec.email         = ["chengkai1853@163.com"]

  spec.summary       = %q{check ios codesign cert and provision valid.}
  spec.description   = %q{check ios codesign cert and provision valid.}
  # spec.homepage      = "wait to upload"
  spec.license       = "MIT"


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = %w{ signvalidator }  
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "plist", "~> 3.0"
  spec.add_runtime_dependency 'colorize' , '~> 0.7', '>= 0.7.7'
end
