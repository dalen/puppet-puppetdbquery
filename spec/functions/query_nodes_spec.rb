#! /usr/bin/env ruby -S rspec

require 'spec_helper'

describe 'query_nodes' do
  context 'without fact parameter' do
    it do
      PuppetDB::Connection.any_instance.expects(:query)
        .with(:nodes, ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['hostname']], ['=', 'value', 'apache4']]]]])
        .returns [
          {
            'certname' => 'apache4.puppetexplorer.io',
            'deactivated' => nil,
            'latest_report_hash' => '4ff9fc5c1344c1c6ce47d923eb139a3409ef530d',
            'facts_environment' => 'production',
            'report_environment' => 'production',
            'catalog_environment' => 'production',
            'facts_timestamp' => '2015-10-13T05:35:32.511Z',
            'expired' => nil,
            'report_timestamp' => '2015-10-13T05:33:17.011Z',
            'catalog_timestamp' => '2015-10-13T05:35:38.661Z',
            'latest_report_status' => 'changed'
          }
        ]
      should run.with_params('hostname="apache4"').and_return(['apache4.puppetexplorer.io'])
    end
  end

  context 'with a fact parameter' do
    it do
      PuppetDB::Connection.any_instance.expects(:query)
        .with(:facts, ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['hostname']], ['=', 'value', 'apache4']]]]], ['or', ['=', 'name', 'ipaddress']]])
        .returns [
          {
            'certname' => 'apache4.puppetexplorer.io',
            'environment' => 'production',
            'name' => 'ipaddress',
            'value' => '172.31.6.80'
          }
        ]
      should run.with_params('hostname="apache4"', 'ipaddress').and_return(['172.31.6.80'])
    end
  end
end
