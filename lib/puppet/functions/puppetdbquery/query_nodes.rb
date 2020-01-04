# This is an autogenerated function, ported from the original legacy version.
# It /should work/ as is, but will not have all the benefits of the modern
# function API. You should see the function docs to learn how to add function
# signatures for type safety and to document this function using puppet-strings.
#
# https://puppet.com/docs/puppet/latest/custom_functions_ruby.html
#
# ---- original file header ----

# ---- original file header ----
#
# @summary
#   
#  accepts two arguments, a query used to discover nodes, and an optional
#  fact that should be returned.
#
#  The query specified should conform to the following format:
#    (Type[title] and fact_name<operator>fact_value) or ...
#    Package["mysql-server"] and cluster_id=my_first_cluster
#
#  The second argument should be single fact or series of keys joined on periods
#  (this argument is optional)
#
#
#
Puppet::Functions.create_function(:'puppetdbquery::query_nodes') do
  # @param args
  #   The original array of arguments. Port this to individually managed params
  #   to get the full benefit of the modern function API.
  #
  # @return [Data type]
  #   Describe what the function returns here
  #
  dispatch :default_impl do
    # Call the method named 'default_impl' when this is matched
    # Port this to match individual params for better type safety
    repeated_param 'Any', :args
  end


  def default_impl(*args)
    
  query, fact = args
  fact_for_query = if fact && fact.match(/\./)
                     fact.split('.').first
                   else
                     fact
                   end

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
  if fact_for_query
    query = parser.facts_query(query, [fact_for_query])
    response = puppetdb.query(:facts, query, :extract => :value)

    if fact.split('.').size > 1
      parser.extract_nested_fact(response, fact.split('.')[1..-1])
    else
      response.collect { |f| f['value'] }
    end
  else
    query = parser.parse(query, :nodes) if query.is_a? String
    puppetdb.query(:nodes, query, :extract => :certname).collect { |n| n['certname'] }
  end

  end
end
