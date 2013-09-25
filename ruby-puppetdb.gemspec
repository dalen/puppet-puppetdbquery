# -*- encoding: UTF-8

lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'puppetdb'

Gem::Specification.new do |s|
  s.name        = "ruby-puppetdb"
  s.version     = PuppetDB::VERSION.join '.'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Bode", "Erik Dalen"]
  s.email       = ["dan@puppetlabs.com", "erik.gustav.dalen@gmail.com"]
  s.homepage    = "https://github.com/dalen/puppet-puppetdbquery"
  s.summary     = %q{Query functions for PuppetDB}
  s.description = %q{A higher level query language for PuppetDB.}
  s.license     = 'Apache v2'


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency('json')
  s.add_dependency('chronic')

  s.add_development_dependency 'rspec', '2.13'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'puppetlabs_spec_helper'
  s.add_development_dependency 'puppet'
  s.add_development_dependency 'racc'
  s.add_development_dependency 'rex'
end
