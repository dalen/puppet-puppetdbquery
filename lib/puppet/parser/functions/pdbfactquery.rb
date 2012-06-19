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
    Puppet::Parser::Functions.autoloader.loadall

    facts = function_pdbquery(["facts/#{args[0]}"])['facts']
    if args.length > 1 then
      facts[args[1]]
    else
      facts
    end
  end
end
