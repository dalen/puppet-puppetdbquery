module Puppet::Parser::Functions
  newfunction(:pdbnodequery, :type => :rvalue, :doc => "\
    Perform a PuppetDB node query

    The first argument is the node query.
    Second argument is optional but allows you to specify a resource query
    that the nodes returned also have to match.

    # Return an array of active nodes with an uptime more than 30 days
    $ret = pdbnodequery(
      ['and',
        ['=',['node','active'],true],
        ['>',['fact','uptime_days'],30]])

    # Return an array of active nodes with an uptime more than 30 days and
    # having the class 'apache'
    $ret = pdbnodequery(
      ['and',
        ['=',['node','active'],true],
        ['>',['fact','uptime_days'],30]],
      ['and',
        ['=',['node','active'],true],
        ['=','type','Class'],
        ['=','title','Apache']])") do |args|
    Puppet::Parser::Functions.autoloader.load(:pdbquery) unless Puppet::Parser::Functions.autoloader.loaded?(:pdbquery)
    Puppet::Parser::Functions.autoloader.load(:pdbresourcequery) unless Puppet::Parser::Functions.autoloader.loaded?(:pdbresourcequery)

    nodeqnodes = function_pdbquery(['nodes', args[0]])

    if args.length > 1 then
      resourceqnodes = function_pdbresourcequery([args[1], 'certname'])

      nodeqnodes & resourceqnodes
    else
      # No resource query to worry about, just return the nodequery
      nodeqnodes
    end
  end
end
