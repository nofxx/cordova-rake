# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'rake/cordova/version'

Gem::Specification.new do |s|
  s.name        = 'rake-cordova'
  s.version     = Rake::Cordova::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Marcos Piccinini']
  s.email       = ['nofxx@github.com']
  s.homepage    = 'http://github.com/nofxx/rake-cordova'
  s.summary     = 'Rake tasks to help cordova development'
  s.description = 'Rake tasks to help cordova development'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
end
