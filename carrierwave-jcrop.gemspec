# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/jcrop/version'

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-jcrop"
  spec.version       = CarrierWave::Jcrop::VERSION
  spec.authors       = ["Kirti Thorat","Voldemar Duletskiy"]
  spec.email         = ["kirti.brenz@gmail.com","voldemar.duletskiy@gmail.com"]
  spec.summary       = %q{Carriewave jcrop helper with support of Mongoid}
  spec.description   = %q{CarrierWave extension to crop uploaded images using Jcrop plugin. Fork of https://github.com/kirtithorat/carrierwave-crop with support of mongoid }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "rspec-rails"
  spec.add_dependency "mini_magick"
  spec.add_dependency "carrierwave"
  spec.add_dependency "carrierwave-mongoid"
  spec.add_dependency "mongoid"
  spec.add_dependency "railties","~> 4.0"
  spec.add_dependency "rails","~> 4.0"
end
