#
# Helper utilities for puppetdb faces
#
#
module PuppetX
  class Puppetdb_query
    def self.setting
      begin
        require 'puppet'
        require 'puppet/util/puppetdb'
        host = Puppet::Util::Puppetdb.server || 'localhost'
        port = Puppet::Util::Puppetdb.port || 8080
      rescue Exception => e
        Puppet.debug(e.message)
        host = 'localhost'
        port = 8080
      end

      Puppet.debug(host)
      Puppet.debug(port)

      { :host => host,
        :port => port }
    end

    def self.add_puppetdb_host_option(action)
      action.option '--puppetdb_host PUPPETDB' do
        summary "Host running PuppetDB. "

        default_to { PuppetX::Puppetdb_query.setting[:host] }
      end
    end

    def self.add_puppetdb_port_option(action)
      action.option '--puppetdb_port PORT' do
        summary 'Port PuppetDB is running on'
        default_to { PuppetX::Puppetdb_query.setting[:port] }
      end
    end

    def self.add_query_option(action)
      # can we make this an argument?
      # --query is a crappy name
      action.option "--query QUERY", "-q QUERY" do
        summary 'query string'
        description <<-EOT
        This uses RI's magic option parser.
        This has to be in single quotes
        (Class[foo] and architecture=i386) or Class[bar]
        EOT
        default_to { '' }
      end
    end

    def self.add_only_active_option(action)
      action.option '--only-active' do
        summary 'only match active nodes'
      end
    end

    # set all of the common defaults to the options
    def self.set_common_defaults(options)
      {
        :puppetdb_host => PuppetX::Puppetdb_query.setting[:host],
        :puppetdb_port => PuppetX::Puppetdb_query.setting[:port],
        :query         => ''
      }.merge(options)
    end
  end
end
