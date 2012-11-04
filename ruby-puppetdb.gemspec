Gem::Specification.new do |s|
  s.name        = "ruby-puppetdb"
  s.version     = %x{git describe --tags}.split('-')[0..1].join('.')
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["RI Pienaar"]
  s.email       = ["rip@devco.net"]
  s.homepage    = "https://github.com/ripienaar/ruby-puppetdb"
  s.summary     = %q{A sample gem}
  s.description = %q{A sample gem. It doesn't do a whole lot, but it's still useful.}


  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features,examples}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
