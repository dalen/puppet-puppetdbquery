require 'rubygems'
require 'json'
require 'rest_client'
require 'puppet/util/puppetdb'

module Puppet::Parser::Functions
  newfunction(:pdbquery, :type => :rvalue, :doc => "\
    Perform a PuppetDB query

    The first argument is the URL path that should be queried, for
    example 'nodes' or 'status/nodes/<nodename>'.
    The second argument if supplied if the query parameter, if it is
    a string it is assumed to be JSON formatted and sent as is,
    anything else is converted to JSON and then sent.

    Example: pdbquery('nodes', ['=', ['node', 'active'], true ])") do |args|
    Puppet.parse_config

    # Query type (URL path)
    t=args[0]

    # Query contents
    if args.length > 1 then
      q=args[1]

      # Convert to JSON if it isn't already
      if ! q.is_a? String then
        q=JSON[q]
      end
      params = {:query => q}
    else
      params = {}
    end

    begin
      response = RestClient::Resource.new(
        "https://#{Puppet::Util::Puppetdb.server}:#{Puppet::Util::Puppetdb.port}/#{t}",
        :ssl_client_cert => OpenSSL::X509::Certificate.new(File.read(Puppet.settings[:hostcert])),
        :ssl_client_key  => OpenSSL::PKey::RSA.new(File.read(Puppet.settings[:hostprivkey])),
        :ssl_ca_file     => Puppet.settings[:localcacert],
        :verify_ssl      => OpenSSL::SSL::VERIFY_PEER
      ).get({
        :accept          => :json,
        :params          => params
      })
    rescue => e
      raise Puppet::ParseError, "PuppetDB query error: #{e.message}"
    end
    JSON.parse(response.to_str)
  end
end
