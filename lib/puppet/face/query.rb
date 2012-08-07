require 'puppet/indirector/face'
Puppet::Face.define(:query, '0.0.1') do

  copyright "Puppet Labs", 2011
  license   "Apache 2 license; see COPYING"


  require 'puppetdb'
  require 'puppet/util/puppetdb'
  require 'puppetX/puppetdb_query'

  PuppetX::Puppetdb_query.add_puppetdb_host_option(self)
  PuppetX::Puppetdb_query.add_puppetdb_port_option(self)
  # TODO get rid of the query and make it an argument
  PuppetX::Puppetdb_query.add_query_option(self)
  PuppetX::Puppetdb_query.add_only_active_option(self)

  action :fact do


    summary 'Serves as an interface to puppetdb allowing a user to query for a list of nodes'

    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    option '--filter FACTS' do
      summary 'facts to return that represent each host'
      description <<-EOT
        Filter for the fact subcommand can be used to specify the facts to filter for.
        It accepts either a string or a comma delimited list of facts.
      EOT
      default_to { '' }
      before_action do |action, args, options|
        options[:filter] = options[:filter].split(',')
      end
    end

    when_invoked do |options|
      p = PuppetDB.new
      nodes = p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query], options[:only_active])
      node_hash = {}
      nodes.each do |node_name|
        node_hash[node_name] = p.find_node_facts(options[:puppetdb_host], options[:puppetdb_port], node_name, options[:filter])
      end
      node_hash
    end

  end

  action :node do

    summary 'Perform complex queries for nodes from PuppetDB'
    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    option '--filter FACTS' do
      summary 'values to return that represent each host'
      description <<-EOT
        Filter is used to specify a single fact value that should be returned for each host.
      EOT
      default_to { nil }
    end

    option '--fail-on-dups' do
      summary 'fail if all returned fact values are not unique'
      default_to { false }
    end

    option '--unique', '--uniq' do
      summary 'only show unique fact values'
      default_to { false }
    end

#  not sure if this is supported
#    option '--only-inactive' do
#      summary 'only match inactive nodes'
#    end

    when_invoked do |options|
      p = PuppetDB.new
      nodes = p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query], options[:only_active])
      if options[:filter]
        nodes.map! do |node_name|
          p.find_node_facts(options[:puppetdb_host], options[:puppetdb_port], node_name, options[:filter]).values[0]
        end
        raise(Puppet::Error, "Duplicate facts found and fail on dups specified") if options[:fail_on_dups] and nodes.uniq.size != nodes.size
        if options[:unique]
          nodes.uniq
        else
          nodes
        end
      else
        nodes
      end
    end

  end
  action :resource do

    summary 'Query for a list of nodes and the resources that should be returned for that node'
    description <<-EOT
      Here is a ton of more useful information :)
    EOT

    option '--filter RESOURCES' do
      summary 'Resources that should be queried out of each host'
      description <<-EOT
        Used to specify the resources that should be queries out of each host.
      EOT
      default_to { '' }
      before_action do |action, args, options|
        options[:filter] = options[:filter].split(',')
      end
    end

    when_invoked do |options|
      p = PuppetDB.new
      # first find the nodes that match the query
      nodes = p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query], options[:only_active])
      nodes.map! do |node_name|
        p.find_node_resources(options[:puppetdb_host], options[:puppetdb_port], node_name, options[:filter])
      end
      munged_hash = {}
      nodes.each do |resources|
        resources.each do |resource|
          id = resource['resource']
          if munged_hash[id]
            munged_hash[id]['nodes'].push(resource['certname'])
          else
            munged_hash[id]               = {}
            munged_hash[id]['type']       = resource['type']
            munged_hash[id]['title']      = resource['title']
            munged_hash[id]['parameters'] = resource['parameters']
            munged_hash[id]['nodes']      = [resource['certname']]
          end
        end
      end
      munged_hash
    end

  end
end
