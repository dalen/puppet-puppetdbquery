Puppet::Parser::Functions.newfunction(:query_resources, :type => :rvalue, :arity => 2, :doc => <<-EOT

  Accepts two arguments: a query used to discover nodes, and a
  resource query for the resources that should be returned from
  those hosts.

  The result is a hash that maps the name of the nodes to a list of
  resource entries.  This is a list because there's no single
  reliable key for resource operations that's of any use to the end user.

  Examples:

    Returns the parameters and such for the ntp class for all CentOS nodes:

      query_resources('operatingsystem=CentOS', 'Class["ntp"]')

    Returns information on the apache user on all nodes that have apache installed on port 443:

      query_resources('Class["apache"]{ port = 443 }', 'User["apache"]')

    Returns the parameters and such for the apache class for all nodes:

      query_resources(false, 'Class["apache"]')

EOT
) do |args|
  nodequery, resquery = args

  require 'puppet/util/puppetdb'
  # This is also needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
  require 'puppetdb/connection'

  puppetdb = PuppetDB::Connection.new(Puppet::Util::Puppetdb.server, Puppet::Util::Puppetdb.port)
  nodequery = puppetdb.parse_query nodequery, :facts if nodequery and nodequery.is_a? String and ! nodequery.empty?
  resquery = puppetdb.parse_query resquery, :none if resquery and resquery.is_a? String and ! resquery.empty?
  return puppetdb.resources(nodequery, resquery)
end
