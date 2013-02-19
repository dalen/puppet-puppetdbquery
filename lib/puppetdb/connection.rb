require 'puppetdb'

class PuppetDB::Connection
  require 'rubygems'
  require 'puppet'
  require 'puppetdb/parser'
  require 'puppet/network/http_pool'
  require 'uri'
  require 'json'

  def initialize(host='puppetdb', port=443, use_ssl=true)
    Puppet.initialize_settings
    @http = Puppet::Network::HttpPool.http_instance(host, port, use_ssl=use_ssl)
    @parser = PuppetDB::Parser.new
  end

  # Parse a query string into a PuppetDB query
  def parse_query(query)
    @parser.scan_str(query).optimize.evaluate
  end

  # Execute a PuppetDB query
  def query(endpoint, query)
    headers = { "Accept" => "application/json" }

    if query == [] or query == nil
      resp, data = @http.get("/v2/#{endpoint.to_s}", headers)
      raise Error, "PuppetDB query error: [#{resp.code}] #{resp.msg}" unless resp.kind_of?(Net::HTTPSuccess)
      return PSON.parse(data)
    else
      params = URI.escape("?query=#{query.to_json}")
      resp, data = @http.get("/v2/#{endpoint.to_s}#{params}", headers)
      raise Error, "PuppetDB query error: [#{resp.code}] #{resp.msg}" unless resp.kind_of?(Net::HTTPSuccess)
      return PSON.parse(data)
    end
  end
end
