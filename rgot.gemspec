# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rgot/version'

Gem::Specification.new do |spec|
  spec.name          = "rgot"
  spec.version       = Rgot::VERSION
  spec.authors       = ["ksss"]
  spec.email         = ["co000ri@gmail.com"]

  spec.summary       = %q{Ruby + Golang Testing = Rgot}
  spec.description   = %q{Rgot is a testing package convert from golang testing}
  spec.homepage      = "https://github.com/ksss/rgot"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|go)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
