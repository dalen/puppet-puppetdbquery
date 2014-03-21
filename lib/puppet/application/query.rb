require 'puppet/application/face_base'

class Puppet::Application::Query < Puppet::Application::FaceBase
  def self.setting
    begin
      require 'puppet'
      require 'puppet/util/puppetdb'
      host = Puppet::Util::Puppetdb.server || 'puppetdb'
      port = Puppet::Util::Puppetdb.port || 8081
      ssl = false
    rescue Exception => e
      Puppet.debug(e.message)
      host = 'puppetdb'
      port = 8081
      ssl = false
    end

    Puppet.debug(host)
    Puppet.debug(port)
    Puppet.debug(ssl)

    { :host => host,
      :port => port,
      :ssl => ssl }
  end
end
