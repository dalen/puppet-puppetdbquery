module Puppet::Parser::Functions
  newfunction(:pdbquery, :type => :rvalue, :doc => "\
    Perform a PuppetDB query

    The first argument is the URL path that should be queried, for
    example 'nodes' or 'status/nodes/<nodename>'.
    The second argument if supplied if the query parameter, if it is
    a string it is assumed to be JSON formatted and sent as is,
    anything else is converted to JSON and then sent.

    Example: pdbquery('nodes', ['=', ['node', 'active'], true ])") do |args|
    require 'rubygems'
    require 'json'
    require 'puppet/network/http_pool'
    require 'uri'
    require 'puppet/util/puppetdb'

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
      params = URI.escape("?query=#{q}")
    else
      params = ''
    end

    url = URI.parse("https://#{Puppet::Util::Puppetdb.server}:#{Puppet::Util::Puppetdb.port}/#{t}#{params}")
    req = Net::HTTP::Get.new(url.request_uri)
    req['Accept'] = 'application/json'
    conn = Puppet::Network::HttpPool.http_instance(url.host, url.port,
                                                   ssl=(url.scheme == 'https'))
    conn.start {|http|
      response = http.request(req)
      unless response.kind_of?(Net::HTTPSuccess)
        raise Puppet::ParseError, "PuppetDB query error: [#{response.code}] #{response.msg}"
      end
      JSON.parse(response.body)
    }
  end
end
