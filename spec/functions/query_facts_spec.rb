#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'puppetdb/connection'

describe 'query_facts' do
  it do
    PuppetDB::Connection.any_instance.stubs(:query).returns [
      { 'certname' => 'apache4.puppetexplorer.io', 'environment' => 'production', 'name' => 'ipaddress', 'value' => '172.31.6.80' }
    ]
    should run.with_params('', ['ipaddress']).and_return('apache4.puppetexplorer.io' => { 'ipaddress' => '172.31.6.80' })
  end
end
