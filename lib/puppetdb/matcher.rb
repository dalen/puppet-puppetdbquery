class PuppetDB
  module Matcher
    autoload :Parser, "puppetdb/matcher/parser"
    autoload :Scanner, "puppetdb/matcher/scanner"

    def self.create_callstack(call_string)
      callstack = Matcher::Parser.new(call_string).execution_stack
    end
  end
end
