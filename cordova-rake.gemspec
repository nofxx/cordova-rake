# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'cordova/rake/version'

Gem::Specification.new do |s|
  s.name        = 'cordova-rake'
  s.version     = Cordova::Rake::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marcos Piccinini']
  s.email       = ['nofxx@github.com']
  s.homepage    = 'http://github.com/nofxx/cordova-rake'
  s.summary     = 'Rake tasks to help cordova development'
  s.description = 'Rake tasks to help cordova development'
  s.license     = 'MIT'

  s.add_dependency('tilt', ['>= 2.0.0'])
  s.add_dependency('paint', ['>= 1.0.0'])
  s.add_dependency('nokogiri', ['>= 1.6.0'])

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
end
