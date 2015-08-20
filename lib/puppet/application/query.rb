require 'puppet/application/face_base'

class Puppet::Application::Query < Puppet::Application::FaceBase
  def self.setting
    use_ssl = true
    begin
      require 'puppet'
      require 'puppet/util/puppetdb'
      host = Puppet::Util::Puppetdb.server || 'puppetdb'
      port = Puppet::Util::Puppetdb.port || 8081
    rescue Exception => e
      Puppet.debug(e.message)
      host = 'puppetdb'
      port = 8081
    end

    Puppet.debug(host)
    Puppet.debug(port)
    Puppet.debug("use_ssl=#{use_ssl}")

    { host: host,
      port: port,
      use_ssl: use_ssl
    }
  end
end
