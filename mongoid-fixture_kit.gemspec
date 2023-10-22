$LOAD_PATH.push(File.expand_path('lib', __dir__))

require 'mongoid/fixture_kit/version'

Gem::Specification.new do |s|
  s.license     = 'MIT'
  s.name        = 'mongoid-fixture_kit'
  s.version     = Mongoid::FixtureKit::VERSION
  s.authors     = ['Dániel Sipos']
  s.email       = ['siposdani87@gmail.com']
  s.homepage    = 'https://github.com/siposdani87/mongoid-fixture-kit'
  s.summary     = 'Fixtures for Rails Mongoid'
  s.description = 'Use fixtures with Mongoid the same way you did with ActiveRecord'
  s.required_ruby_version = '>= 3.1.0'

  s.files = Dir['{lib}/**/*', 'LICENSE', 'Rakefile', 'README.rdoc']

  s.add_dependency('activesupport', '~> 7.0')
  s.add_dependency('mongoid',       '>= 7.0')
  s.metadata['rubygems_mfa_required'] = 'true'
end
