Puppet::Parser::Functions.newfunction(:query_active_nodes, :type => :rvalue, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a filter used to
  specify the fact that should be returned.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package[mysql-server] and cluster_id=my_first_cluster

  The filter provided should be a single fact (this argument is optional)

EOT
) do |args|
  query, filter = args
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppetdb'))
  raise(Puppet::Error, 'Query is a required parameter') unless query
  PuppetDB.new.query_nodes(:query => query, :filter => filter, :only_active => true)
end
