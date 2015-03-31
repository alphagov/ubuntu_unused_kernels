# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ubuntu_unused_kernels/version'

Gem::Specification.new do |spec|
  spec.name          = "ubuntu_unused_kernels"
  spec.version       = UbuntuUnusedKernels::VERSION
  spec.authors       = ["Dan Carley"]
  spec.email         = ["dan.carley@gmail.com"]
  spec.summary       = %q{Identify unused Ubuntu kernels}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/gds-operations/ubuntu_unused_kernels"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "gem_publisher"
end
