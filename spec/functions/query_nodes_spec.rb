#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe 'query_nodes' do
  context 'without fact parameter' do
    it do
      PuppetDB::Connection.any_instance.expects(:query)
        .with(:nodes, ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['hostname']], ['=', 'value', 'apache4']]]]], :extract => :certname)
        .returns [ { 'certname' => 'apache4.puppetexplorer.io' } ]
      should run.with_params('hostname="apache4"').and_return(['apache4.puppetexplorer.io'])
    end
  end

  context 'with a fact parameter' do
    it do
      PuppetDB::Connection.any_instance.expects(:query)
        .with(:facts, ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['hostname']], ['=', 'value', 'apache4']]]]], ['or', ['=', 'name', 'ipaddress']]], :extract => :value)
        .returns [ { 'value' => '172.31.6.80' } ]
      should run.with_params('hostname="apache4"', 'ipaddress').and_return(['172.31.6.80'])
    end
  end
end
