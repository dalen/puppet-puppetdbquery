Puppet::Parser::Functions.newfunction(:query_nodes, :type => :rvalue, :arity => -2, :doc => <<-EOT

  accepts two arguments, a query used to discover nodes, and a optional
  fact that should be returned.

  The query specified should conform to the following format:
    (Type[title] and fact_name<operator>fact_value) or ...
    Package["mysql-server"] and cluster_id=my_first_cluster

  The second argument should be single fact (this argument is optional)

EOT
                                     ) do |args|
  query, fact = args

  require 'puppet/util/puppetdb'

  # This is needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..'))
  begin
    require 'puppetdb/connection'
  ensure
    $LOAD_PATH.shift
  end

  PuppetDB::Connection.check_version

  uri = URI(Puppet::Util::Puppetdb.config.server_urls.first)
  puppetdb = PuppetDB::Connection.new(uri.host, uri.port, uri.scheme == 'https')
  parser = PuppetDB::Parser.new
  if fact
    query = parser.facts_query(query, [fact])
    puppetdb.query(:facts, query, :extract => :value).collect { |f| f['value'] }
  else
    query = parser.parse(query, :nodes) if query.is_a? String
    puppetdb.query(:nodes, query, :extract => :certname).collect { |n| n['certname'] }
  end
end
