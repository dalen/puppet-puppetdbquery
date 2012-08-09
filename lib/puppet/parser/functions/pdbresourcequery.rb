module Puppet::Parser::Functions
  newfunction(:pdbresourcequery, :type => :rvalue, :doc => "\
    Perform a PuppetDB resource query

    The first argument is the resource query.
    Second argument is optional but allows you to specify the item you want
    from the returned hash.

    Examples:
    # Return an array of hashes describing all files that are owned by root.
    $ret = pdbresourcequery(
      ['and',
        ['=',['node','active'],true],
        ['=','type','File'],
        ['=',['parameter','owner'],'root']])

    # Return an array of host names having those resources
    $ret = pdbresourcequery(
      ['and',
        ['=',['node','active'],true],
        ['=','type','File'],
        ['=',['parameter','owner'],'root']], 'certname')") do |args|
    Puppet::Parser::Functions.autoloader.load(:pdbquery) unless Puppet::Parser::Functions.autoloader.loaded?(:pdbquery)

    ret = function_pdbquery(['resources', args[0]])
    if args.length > 1 then
      ret = ret.collect {|x| x[args[1]]}
    end

    ret
  end
end
