Puppet::Parser::Functions.newfunction(:query_nodes, :type => :rvalue, :arity => 1, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a filter used to
  specify the fact that should be returned.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package["mysql-server"] and cluster_id=my_first_cluster

  The filter provided should be a single fact (this argument is optional)

EOT
) do |args|
  query = args

  require 'puppet/util/puppetdb'
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppetdb/connection'))

  puppetdb = PuppetDB::Connection.new(Puppet::Util::Puppetdb.server, Puppet::Util::Puppetdb.port)
  if query.is_a? String then
    query = puppetdb.parse_query query
  end
  puppetdb.query(:nodes, query)
end
