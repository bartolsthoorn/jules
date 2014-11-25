require File.expand_path('../lib/jules/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'jules'
  s.version     = Jules::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Bart Olsthoorn']
  s.email       = ['bartolsthoorn@gmail.com']
  s.homepage    = 'http://github.com/bartolsthoorn/jules'
  s.summary     = s.description = 'Data mining scraper using local hashing.'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.0'

  s.add_dependency 'nokogiri'
  s.add_dependency 'simhash'
  s.add_dependency 'descriptive_statistics'

  s.files        = Dir.glob('lib/**/*') + %w(README.md)
  s.require_paths = ['lib']
end
