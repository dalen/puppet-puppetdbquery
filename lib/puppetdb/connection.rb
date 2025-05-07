# frozen_string_literal: true

require 'puppetdb'
require 'rubygems'
require 'puppetdb/parser'
require 'uri'
require 'puppet'
require 'puppet/util/logging'
require 'json'

class PuppetDB::Connection
  include Puppet::Util::Logging

  def initialize(host = 'puppetdb', port = 443, use_ssl = true)
    @host = host
    @port = port
    @use_ssl = use_ssl
  end

  def self.check_version
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

  # Execute a PuppetDB query
  #
  # @param endpoint [Symbol] :resources, :facts or :nodes
  # @param query [Array] query to execute
  # @param options [Hash] specify extract values or http connection
  # @return [Array] the results of the query
  def query(endpoint, query = nil, options = {}, version = :v4)

    default_options = {
      :http => nil,   # A HTTP object to be used for the connection
      :extract => nil, # An array of fields to extract
      :source => 'face' # Source of request (face or function)
    }

    if options.is_a? Hash
      options = default_options.merge options
    else
      Puppet.deprecation_warning 'Specify http object with :http key instead'
      options = default_options.merge(:http => options)
    end

    source = options[:source]
    http = options[:http] || Puppet.runtime[:http]
    headers = { 'Accept' => 'application/json' }

    query = PuppetDB::ParserHelper.extract(*Array(options[:extract]), query) if options[:extract]

    uri = URI("#{@use_ssl ? 'https' : 'http'}://#{@host}:#{@port}/pdb/query/#{version}/#{endpoint}")
    _query = "#{query.to_json}" unless query.nil? || query.empty?
    uri.query = (source == 'function' ? URI.encode_www_form(query: _query) : "query=#{_query}") unless _query.empty?

    debug("PuppetDB uri: #{uri.to_s}")
    debug("PuppetDB query: #{query.to_json}")

    resp = http.get(uri, headers: headers)
    raise "PuppetDB query error: [#{resp.code}] #{resp.reason}, url: #{uri.to_s}, query: #{query.to_json}" unless resp.success?
    JSON.parse(resp.body)
  end
end
