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
      nodes.map! do |node_name|
        p.find_node_resources(options[:puppetdb_host], options[:puppetdb_port], node_name, options[:filter])
      end
      munged_hash = {}
      nodes.each do |resources|
        resources.compact.each do |resource|
          # NOTE - I am not happy with the fact that I am returning different hashes
          # depending on if we care about conflicts or not.
          # I should probably have the type/title hash to an array of the variations
          # instead of this,but for now, this is easier
          if options[:allow_conflicts]
            id = resource['resource']
          else
            id = "#{resource['type']}[#{resource['title']}]"
          end
          if munged_hash[id]
            # if the ids are the same, then push it, otherwise fail
            if options[:allow_conflicts] || munged_hash[id]['resource_hash'] == resource['resource']
              munged_hash[id]['nodes'].push(resource['certname'])
            else
              # failing on conflicts allows me to key the resources off of type/title
              # I probably need to return a different data structure if I allow conflicts
              raise(Puppet::Error, "Conflicting definitions of resource #{id} were found on #{resource['certname']} and #{munged_hash[id]['nodes'].inspect}")
            end
          else
            munged_hash[id]                    = {}
            munged_hash[id]['parameters']      = resource['parameters']
            munged_hash[id]['nodes']           = [resource['certname']]
            if options[:allow_conflicts]
              munged_hash[id]['reference']     = "#{resource['type']}[#{resource['title']}]"
            else
              munged_hash[id]['resource_hash'] = resource['resource']
            end
          end
        end
      end
      munged_hash
    end

  end
end
