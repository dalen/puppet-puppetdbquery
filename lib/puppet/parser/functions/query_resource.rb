require 'puppet/face'
Puppet::Parser::Functions.newfunction(:query_resource, :type => :rvalue, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a filter used to
  specify the resources that should be returned from those hosts.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package[mysql-server] and cluster_id=my_first_cluster

  The filter provided should be a comma delimited list of resource references.

EOT
) do |args|
  filter, query = args
  query ||= ''
  # check that the filter is only one resource
  raise(Puppet::Error, 'Must specify at least one argument (resource to query for)') unless filter
  result = Puppet::Face[:query, :current].resource(:query => query, :filter => filter)
  raise(Puppet::Error, 'Function should only return one resource') if result.size > 1
  {result.keys.first => result.values.first.first}
end
