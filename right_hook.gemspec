# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'right_hook/version'

Gem::Specification.new do |spec|
  spec.name          = "right_hook"
  spec.version       = RightHook::VERSION
  spec.authors       = ["Mark Rushakoff"]
  spec.email         = ["mark.rushakoff@gmail.com"]
  spec.description   = %q{A collection of tools for making web apps that respond to GitHub hooks.}
  spec.summary       = %q{Right Hook is a foundation to use when you just want to write a GitHub service hook.}
  spec.homepage      = "https://github.com/mark-rushakoff/right_hook"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "webmock", "~> 1.13"
  spec.add_development_dependency "coveralls"

  spec.add_runtime_dependency "sinatra", "~> 1.4"
  spec.add_runtime_dependency "httparty", "~> 0.11.0"
  spec.add_runtime_dependency "octokit", "~> 2.2"
end
