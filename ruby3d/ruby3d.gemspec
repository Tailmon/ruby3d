# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruby3d/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby3d'
  spec.version       = Ruby3d::VERSION
  spec.authors       = ['Pablo Sanabria']
  spec.email         = ['pablo.s.q1.4.1991@gmail.com']
  spec.description   = 'This gem is an initial prototype for the new 3D RubyEngine'
  spec.summary       = 'A 3D Ruby Engine'
  spec.homepage      = 'http://rubygems.org/gems/RubyEngine'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'opengl', '>= 0.8.0'
  spec.add_dependency 'rmagick'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
