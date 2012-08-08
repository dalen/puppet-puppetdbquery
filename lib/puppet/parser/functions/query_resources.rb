require 'puppet/face'
Puppet::Parser::Functions.newfunction(:query_resources, :type => :rvalue, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a filter used to
  specify the resources that should be returned from those hosts.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package[mysql-server] and cluster_id=my_first_cluster

  The filter provided should be a comma delimited list of resource references.

EOT
) do |args|
  query, filter = args
  raise(Puppet::Error, 'Query is a required parameter') unless query
  Puppet::Face[:query, :current].resource(:query => query, :filter => filter)
end
