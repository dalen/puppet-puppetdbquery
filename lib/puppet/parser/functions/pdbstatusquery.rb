module Puppet::Parser::Functions
  newfunction(:pdbstatusquery, :type => :rvalue, :doc => "\
    Perform a PuppetDB node status query

    The first argument is the node to get facts for.
    Second argument is optional, if specified only return that specific bit of
    status, one of 'name', 'deactivated', 'catalog_timestamp' and 'facts_timestamp'.

    Examples:
    # Get status for foo.example.com
    pdbstatusquery('foo.example.com')
    # Get catalog_timestamp for foo.example.com
    pdbstatusquery('foo.example.com', 'catalog_timestamp')") do |args|
    Puppet::Parser::Functions.autoloader.load(:pdbquery) unless Puppet::Parser::Functions.autoloader.loaded?(:pdbquery)

    ret = function_pdbquery(["status/nodes/#{args[0]}"])
    if args.length > 1 then
      ret[args[1]]
    else
      ret
    end
  end
end
