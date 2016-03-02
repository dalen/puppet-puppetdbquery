#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'puppetdb/connection'

describe 'query_facts' do
  it do
    PuppetDB::Connection.any_instance.expects(:query)
      .with(:facts, ['or', ['=', 'name', 'ipaddress']], {:extract => [:certname, :name, :value]})
      .returns [
        { 'certname' => 'apache4.puppetexplorer.io', 'environment' => 'production', 'name' => 'ipaddress', 'value' => '172.31.6.80' }
      ]
    should run.with_params('', ['ipaddress']).and_return('apache4.puppetexplorer.io' => { 'ipaddress' => '172.31.6.80' })
  end

  it do
    PuppetDB::Connection.any_instance.expects(:query)
      .with(:facts, ['or', ['=', 'name', 'ipaddress'], ['=', 'name', 'network_eth0']], {:extract => [:certname, :name, :value]})
      .returns [
        { 'certname' => 'apache4.puppetexplorer.io', 'environment' => 'production', 'name' => 'ipaddress', 'value' => '172.31.6.80' },
        { 'certname' => 'apache4.puppetexplorer.io', 'environment' => 'production', 'name' => 'network_eth0', 'value' => '172.31.0.0' }
      ]
    should run.with_params('', ['ipaddress', 'network_eth0']).and_return('apache4.puppetexplorer.io' => { 'ipaddress' => '172.31.6.80', 'network_eth0' => '172.31.0.0' })
  end
end
