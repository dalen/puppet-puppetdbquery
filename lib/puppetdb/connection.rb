require 'puppetdb'

class PuppetDB::Connection
  require 'rubygems'
  require 'puppetdb/parser'
  require 'uri'
  require 'puppet'
  require 'puppet/util/logging'

  include Puppet::Util::Logging

  def initialize(host = 'puppetdb', port = 443, use_ssl = true)
    @host = host
    @port = port
    @use_ssl = use_ssl
  end

  def self.check_version
    begin
      require 'puppet/util/puppetdb'
      unless Puppet::Util::Puppetdb.config.respond_to?('server_urls')
        Puppet.warning <<-EOT
It looks like you are using a PuppetDB version < 3.0.
This version of puppetdbquery requires at least PuppetDB 3.0 to work.
Downgrade to puppetdbquery 1.x to use it with PuppetDB 2.x.
EOT
      end
    rescue LoadError
    end
  end

  # Get the listed facts for all nodes matching query
  # return it as a hash of hashes
  #
  # @param facts [Array] the list of facts to fetch
  # @param nodequery [Array] the query to find the nodes to fetch facts for
  # @return [Hash] a hash of hashes with facts for each node mathing query
  def facts(facts, nodequery, http = nil)
    if facts.empty?
      q = ['in', 'certname', ['extract', 'certname', ['select_facts', nodequery]]]
    else
      q = ['and', ['in', 'certname', ['extract', 'certname', ['select_facts', nodequery]]], ['or', *facts.collect { |f| ['=', 'name', f] }]]
    end
    facts = {}
    query(:facts, q, http).each do |fact|
      if facts.include? fact['certname']
        facts[fact['certname']][fact['name']] = fact['value']
      else
        facts[fact['certname']] = { fact['name'] => fact['value'] }
      end
    end
    facts
  end

  # Get the listed resources for all nodes matching query
  # return it as a hash of hashes
  #
  # @param resquery [Array] a resources query for what resources to fetch
  # @param nodequery [Array] the query to find the nodes to fetch resources for, optionally empty
  # @param grouphosts [Boolean] whether or not to group the results by the host they belong to
  # @return [Hash|Array] a hash of hashes with resources for each node mathing query or array if grouphosts was false
  def resources(nodequery, resquery, http = nil, grouphosts = true)
    if resquery && !resquery.empty?
      if nodequery && !nodequery.empty?
        q = ['and', resquery, nodequery]
      else
        q = resquery
      end
    else
      fail "PuppetDB resources query error: at least one argument must be non empty; arguments were: nodequery: #{nodequery.inspect} and requery: #{resquery.inspect}"
    end
    resources = {}
    results = query(:resources, q, http)

    if grouphosts
      results.each do |resource|
        unless resources.key? resource['certname']
          resources[resource['certname']] = []
        end
        resources[resource['certname']] << resource
      end
    else
      resources = results
    end

    resources
  end

  # Execute a PuppetDB query
  #
  # @param endpoint [Symbol] :resources, :facts or :nodes
  # @param query [Array] query to execute
  # @return [Array] the results of the query
  def query(endpoint, query = nil, http = nil, version = :v4)
    require 'json'

    unless http
      require 'puppet/network/http_pool'
      http = Puppet::Network::HttpPool.http_instance(@host, @port, @use_ssl)
    end
    headers = { 'Accept' => 'application/json' }

    uri = "/pdb/query/#{version}/#{endpoint}"
    uri += URI.escape "?query=#{query.to_json}" unless query.nil? || query.empty?

    debug("PuppetDB query: #{query.to_json}")

    resp = http.get(uri, headers)
    fail "PuppetDB query error: [#{resp.code}] #{resp.msg}, query: #{query.to_json}" unless resp.is_a?(Net::HTTPSuccess)
    JSON.parse(resp.body)
  end
end
