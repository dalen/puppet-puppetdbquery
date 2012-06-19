# Copyright (C) 2012 Erik Dalén
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THOMAS BELLMAN BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Except as contained in this notice, the name of Thomas Bellman shall
# not be used in advertising or otherwise to promote the sale, use or
# other dealings in this Software without prior written authorization
# from Erik Dalén.

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
    JSON.parse(response.to_str)
  end
end
