Gem::Specification.new do |s|
  s.name        = "ruby-puppetdb"
  s.version     = %x{git describe --tags}.split('-')[0..1].join('.')
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dan Bode", "Erik Dalén"]
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
end
