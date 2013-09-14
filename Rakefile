require 'rubygems'
require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
  t.rspec_opts = ['--color']
end

desc "Generate Lexer and Parser"
task :generate => [:lexer, :parser]

desc "Generate Parser"
task :parser do
    `racc lib/puppetdb/grammar.y -o lib/puppetdb/parser.rb --superclass='PuppetDB::Lexer'`
end

desc "Generate Lexer"
task :lexer do
    `rex lib/puppetdb/lexer.l -o lib/puppetdb/lexer.rb`
end
