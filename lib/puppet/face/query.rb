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

    option '--allow-conflicts' do
      summary 'If conflicting resources should be returned, or raise an exception.'
      description <<-EOT
      If parameter conflicts between resources should raise an exception.
      By default if the same resources is returned with multiple different variations,
      an exception is raised.
      Unfortunately, allow-conflicts also changes the format of the hashes that are returned.
      If it is set to false, the type/title pairs hash to the resources, otherwise, the
      resource hash is used to hash to the resources.
      I am not currently happy with this implementation and it is likely to change.
      EOT
      default_to { false }
    end

    when_invoked do |options|
      p = PuppetDB.new
      # first find the nodes that match the query
      nodes = p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query], options[:only_active])
      # now use the filter to find the specified resources for that node
      nodes.map! do |node_name|
        p.find_node_resources(options[:puppetdb_host], options[:puppetdb_port], node_name, options[:filter])
      end
      # compact the resource for all nodes into
      # a single simplified list
      munged_resources = p.compact_nodes_resources(nodes)
      if conflict = p.has_conflicts?(munged_resources) and options[:allow_conflicts]
        params = munged_resources[conflict].collect {|x| x['parameters'] }
        raise(Puppet::Error, "Conflicting definitions of resource #{conflict} #{params.inspect}")
      end
      munged_resources
    end

  end
end
