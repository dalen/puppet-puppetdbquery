module Puppet::Parser::Functions
  newfunction(:pdbnodequery, :type => :rvalue, :doc => "\
    Perform a PuppetDB node query

    The first argument is the node query.
    Second argument is optional but allows you to specify a resource query
    that the nodes returned also have to match.

    Examples:
    # Return an array of active nodes with an uptime more than 30 days
    pdbnodequery(['and',['=',['node','active'],true],['>',['fact','uptime_days'],30]])

    # Return an array of active nodes with an uptime more than 30 days and
    # having the class 'apache'
    pdbnodequery(['and',['=',['node','active'],true],['>',['fact','uptime_days'],30]],
      ['and',['=','type','Class'],['=','title','Apache']])") do |args|
    Puppet::Parser::Functions.autoloader.loadall

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
