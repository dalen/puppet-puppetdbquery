# The `puppetdb_lookup_key` is a hiera 5 `lookup_key` data provider function.
# See (https://docs.puppet.com/puppet/latest/hiera_custom_lookup_key.html) for
# more info.
#
# See README.md#hiera-backend for usage.
#
Puppet::Functions.create_function(:puppetdb_lookup_key) do
  require 'puppet/util/puppetdb'

  # This is needed if the puppetdb library isn't pluginsynced to the master
  $LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  begin
    require 'puppetdb/connection'
  ensure
    $LOAD_PATH.shift
  end

  dispatch :puppetdb_lookup_key do
    param 'String[1]', :key
    param 'Hash[String[1],Any]', :options
    param 'Puppet::LookupContext', :context
  end

  def parser
    @parser ||= PuppetDB::Parser.new
  end

  def puppetdb
    @uri ||= URI(Puppet::Util::Puppetdb.config.server_urls.first)
    @puppetdb ||= PuppetDB::Connection.new(
      @uri.host,
      @uri.port,
      @uri.scheme == 'https'
    )
  end

  def puppetdb_lookup_key(key, options, context)
    if !key.end_with?('::_nodequery') && nodequery = call_function('lookup', ["#{key}::_nodequery", 'Data', 'first', nil])
      # Support specifying the query in a few different ways
      if nodequery.is_a? Hash
        query = nodequery['query']
        fact = nodequery['fact']
      elsif nodequery.is_a? Array
        query, fact = *nodequery
      else
        query = nodequery.to_s
      end

      if fact
        query = @parser.facts_query query, [fact]
        @puppetdb.query(:facts, query).collect { |f| f['value'] }.sort
      else
        query = @parser.parse query, :nodes if query.is_a? String
        @puppetdb.query(:nodes, query).collect { |n| n['name'] }
      end
    else
      context.not_found
    end
  end
end
