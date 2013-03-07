require 'puppetdb'

class PuppetDB::Connection
  require 'rubygems'
  require 'puppet'
  require 'puppetdb/parser'
  require 'puppet/network/http_pool'
  require 'uri'
  require 'json'

  def initialize(host='puppetdb', port=443, use_ssl=true)
    @host = host
    @port = port
    @use_ssl = use_ssl
    @parser = PuppetDB::Parser.new
  end

  # Parse a query string into a PuppetDB query
  #
  # @param query [String] the query string to parse
  # @param endpoint [Symbol] the endpoint for which the query should be evaluated
  # @return [Array] the PuppetDB query
  def parse_query(query, endpoint=:nodes)
    @parser.scan_str(query).optimize.evaluate endpoint
  end

  # Get the listed facts for all nodes matching query
  # return it as a hash of hashes
  #
  # @param facts [Array] the list of facts to fetch
  # @param nodequery [Array] the query to find the nodes to fetch facts for
  # @return [Hash] a hash of hashes with facts for each node mathing query
  def facts(facts, nodequery, http=nil)
    q = ['and', ['in', 'certname', ['extract', 'certname', ['select-facts', nodequery]]], ['or', *facts.collect { |f| ['=', 'name', f]}]]
    facts = {}
    query(:facts, q, http).each do |fact|
      if facts.include? fact['certname'] then
        facts[fact['certname']][fact['name']] = fact['value']
      else
        facts[fact['certname']] = {fact['name'] => fact['value']}
      end
    end
    facts
  end

  # Execute a PuppetDB query
  #
  # @param endpoint [Symbol] :resources, :facts or :nodes
  # @param query [Array] query to execute
  # @return [Array] the results of the query
  def query(endpoint, query=nil, http=nil)
    http ||= Puppet::Network::HttpPool.http_instance(@host, @port, @use_ssl)
    headers = { "Accept" => "application/json" }

    uri = "/v2/#{endpoint.to_s}"
    uri += URI.escape "?query=#{query.to_json}" unless query.nil? or query.empty?

    resp, data = http.get(uri, headers)
    raise Puppet::Error, "PuppetDB query error: [#{resp.code}] #{resp.msg}, query: #{query.to_json}" unless resp.kind_of?(Net::HTTPSuccess)
    return PSON.parse(data)
  end
end
