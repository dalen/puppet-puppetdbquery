class PuppetDB
  module Matcher
    puppetdb_dir = File.expand_path(File.dirname(__FILE__))
    autoload :Parser, File.join(puppetdb_dir, 'matcher', 'parser')
    autoload :Scanner, File.join(puppetdb_dir, 'matcher', 'scanner')

    def self.create_callstack(call_string)
      callstack = Matcher::Parser.new(call_string).execution_stack
    end
  end
end
