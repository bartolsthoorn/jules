# -*- encoding: utf-8 -*-
require File.expand_path('../lib/jules/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'jules'
  s.version     = Jules::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Bart Olsthoorn']
  s.email       = ['bartolsthoorn@gmail.com']
  s.homepage    = 'http://github.com/bartolsthoorn/jules'
  s.summary     = s.description = 'High level data mining scraper using patterns, semantics and NLP.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.0'

  s.add_dependency 'nokogiri'
  s.add_dependency 'whatlanguage'
  s.add_dependency 'damerau-levenshtein'

  s.add_development_dependency 'rspec'

  s.files        = Dir.glob('lib/**/*') + %w(LICENSE README.md)
  s.require_paths = ['lib']
end
