Puppet::Parser::Functions.newfunction(:query_facts, :type => :rvalue, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a filter used to
  specify the facts that should be returned from those hosts.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package[mysql-server] and cluster_id=my_first_cluster

  The filter provided should be a comma delimited list of fact names.

  The result is a hash that maps the name of the nodes to a hash of facts that
  contains the filters specified.

EOT
) do |args|
  filter, query = args
  query ||= ''
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'puppetdb'))
  # check that the filter is only one resource
  raise(Puppet::Error, 'Must specify at least one argument (fact to query for)') unless filter
  result = PuppetDB.new.query_facts(:query => query, :filter => filter)
end
