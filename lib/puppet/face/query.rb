require 'puppet/application/query'
require 'puppet/face'
Puppet::Face.define(:query, '1.0.0') do
  require 'puppetdb/connection'

  copyright "Puppet Labs & Erik Dalen", 2012..2013
  license   "Apache 2 license; see COPYING"


  option '--puppetdb_host PUPPETDB' do
    summary "Host running PuppetDB. "
    default_to { Puppet::Application::Query.setting[:host] }
  end

  option '--puppetdb_port PORT' do
    summary 'Port PuppetDB is running on'
    default_to { Puppet::Application::Query.setting[:port] }
  end

  action :facts do
    summary 'Serves as an interface to puppetdb allowing a user to query for a list of nodes'

    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    arguments "<query>"

    option '--facts FACTS' do
      summary 'facts to return that represent each host'
      description <<-EOT
        Filter for the fact subcommand can be used to specify the facts to filter for.
        It accepts either a string or a comma delimited list of facts.
      EOT
      default_to { '' }
    end

    when_invoked do |query, options|
      puppetdb = PuppetDB::Connection.new options[:puppetdb_host], options[:puppetdb_port]
      puppetdb.facts(options[:facts].split(','), puppetdb.parse_query(query, :facts))
    end

  end

  action :nodes do

    summary 'Perform complex queries for nodes from PuppetDB'
    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    arguments "<query>"

    option '--node_info BOOLEAN' do
      summary 'return full info about each node or just name'
      description <<-EOT
        If true the full information about each host is returned including fact, report and catalog timestamps.
      EOT
      default_to { false }
    end

    when_invoked do |query, options|
      puppetdb = PuppetDB::Connection.new options[:puppetdb_host], options[:puppetdb_port]
      nodes = puppetdb.query(:nodes, puppetdb.parse_query(query, :nodes))
      if options[:node_info]
        nodes
      else
        nodes.collect { |node| node['name'] } unless options[:node_info]
      end
    end

  end
end
