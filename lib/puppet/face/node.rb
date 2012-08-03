require 'puppet/indirector/face'
Puppet::Indirector::Face.define(:node, '0.0.1') do
  copyright "Puppet Labs", 2011
  license   "Apache 2 license; see COPYING"
  action :query do

    require 'puppetdb'
    require 'puppet/util/puppetdb'

    summary 'Perform complex queries for nodes from PuppetDB'
    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    option '--puppetdb_host PUPPETDB' do
      summary "Host running PuppetDB. "
      default_to { 'localhost' }
    end

    option '--puppetdb_port PORT' do
      summary 'Port PuppetDB is running on'
      default_to { 8080 }
    end

    option "--query QUERY", "-q QUERY" do
      summary 'query string'
      default_to { '' }
    end

    when_invoked do |options|
      p = PuppetDB.new
      p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query])
    end

  end
end
