module Puppet::Parser::Functions
  newfunction(:pdbfactquery, :type => :rvalue, :doc => "\
    Perform a PuppetDB fact query

    The first argument is the node to get facts for.
    Second argument is optional, if specified only return that specific fact.

    Examples:
    # Get hash of facts for foo.example.com
    pdbfactquery('foo.example.com')
    # Get the uptime fact for foo.example.com
    pdbfactquery('foo.example.com', 'uptime')") do |args|

    raise(Puppet::ParseError, "pdbquery(): Wrong number of arguments " +
                "given (#{args.size} for 1 or 2)") if args.size < 1 or args.size > 2

    Puppet::Parser::Functions.autoloader.load(:pdbquery) unless Puppet::Parser::Functions.autoloader.loaded?(:pdbquery)

    if args[0].is_a?(Array) then
      if args.length > 1 then
        args[0].collect { |n| function_pdbfactquery([n,args[1]]) }
      else
        args[0].collect { |n| function_pdbfactquery([n]) }
      end
    else
      facts = function_pdbquery(["facts/#{args[0]}"])['facts']
      if args.length > 1 then
        facts[args[1]]
      else
        facts
      end
    end
  end
end
