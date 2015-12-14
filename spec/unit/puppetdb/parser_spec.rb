#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'puppetdb/parser'

describe PuppetDB::Parser do
  context 'Query parsing' do
    let(:parser) { PuppetDB::Parser.new }
    it 'should handle empty queries' do
      parser.parse('').should be_nil
    end

    it 'should handle double quoted strings' do
      parser.parse('foo="bar"').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['=', 'value', 'bar']]]]]
    end

    it 'should handle single quoted strings' do
      parser.parse('foo=\'bar\'').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['=', 'value', 'bar']]]]]
    end

    it 'should handle = operator' do
      parser.parse('foo=bar').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['=', 'value', 'bar']]]]]
    end

    it 'should handle != operator' do
      parser.parse('foo!=bar').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['not', ['=', 'value', 'bar']]]]]]
    end

    it 'should handle ~ operator' do
      parser.parse('foo~bar').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['~', 'value', 'bar']]]]]
    end

    it 'should handle !~ operator' do
      parser.parse('foo!~bar').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['not', ['~', 'value', 'bar']]]]]]
    end

    it 'should handle >= operator' do
      parser.parse('foo>=1').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['>=', 'value', 1]]]]]
    end

    it 'should handle <= operator' do
      parser.parse('foo<=1').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['<=', 'value', 1]]]]]
    end

    it 'should handle > operator' do
      parser.parse('foo>1').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['>', 'value', 1]]]]]
    end

    it 'should handle < operator' do
      parser.parse('foo<1').should eq \
        ['in', 'certname',
         ['extract', 'certname',
          ['select_fact_contents',
           ['and',
            ['=', 'path', ['foo']],
            ['<', 'value', 1]]]]]
    end

    it 'should handle precedence' do
      parser.parse('foo=1 or bar=2 and baz=3').should eq ['or', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['foo']], ['=', 'value', 1]]]]], ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['bar']], ['=', 'value', 2]]]]], ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['baz']], ['=', 'value', 3]]]]]]]
      parser.parse('(foo=1 or bar=2) and baz=3').should eq ['and', ['or', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['foo']], ['=', 'value', 1]]]]], ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['bar']], ['=', 'value', 2]]]]]], ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['baz']], ['=', 'value', 3]]]]]]
    end

    it 'should parse resource queries for exported resources' do
      parser.parse('@@file[foo]').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'File'], ['=', 'title', 'foo'], ['=', 'exported', true]]]]]
    end

    it 'should parse resource queries with type, title and parameters' do
      parser.parse('file[foo]{bar=baz}').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'File'], ['=', 'title', 'foo'], ['=', 'exported', false], ['=', %w(parameter bar), 'baz']]]]]
    end

    it 'should parse resource queries with tags' do
      parser.parse('file[foo]{tag=baz}').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'File'], ['=', 'title', 'foo'], ['=', 'exported', false], ['=', 'tag', 'baz']]]]]
    end

    it 'should handle precedence within resource parameter queries' do
      parser.parse('file[foo]{foo=1 or bar=2 and baz=3}').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'File'], ['=', 'title', 'foo'], ['=', 'exported', false], ['or', ['=', %w(parameter foo), 1], ['and', ['=', %w(parameter bar), 2], ['=', %w(parameter baz), 3]]]]]]]
      parser.parse('file[foo]{(foo=1 or bar=2) and baz=3}').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'File'], ['=', 'title', 'foo'], ['=', 'exported', false], ['and', ['or', ['=', %w(parameter foo), 1], ['=', %w(parameter bar), 2]], ['=', %w(parameter baz), 3]]]]]]
    end

    it 'should capitalize class names' do
      parser.parse('class[foo::bar]').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'Class'], ['=', 'title', 'Foo::Bar'], ['=', 'exported', false]]]]]
    end

    it 'should parse resource queries with regeexp title matching' do
      parser.parse('class[~foo]').should eq ['in', 'certname', ['extract', 'certname', ['select_resources', ['and', ['=', 'type', 'Class'], ['~', 'title', 'foo'], ['=', 'exported', false]]]]]
    end

    it 'should be able to negate expressions' do
      parser.parse('not foo=bar').should eq ['not', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['foo']], ['=', 'value', 'bar']]]]]]
    end

    it 'should handle single string expressions' do
      parser.parse('foo.bar.com').should eq ['~', 'certname', 'foo\\.bar\\.com']
    end

    it 'should handle structured facts' do
      parser.parse('foo.bar=baz').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', %w(foo bar)], ['=', 'value', 'baz']]]]]
    end

    it 'should handle structured facts with array component' do
      parser.parse('foo.bar.0=baz').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['foo', 'bar', 0]], ['=', 'value', 'baz']]]]]
    end

    it 'should handle structured facts with match operator' do
      parser.parse('foo.bar.~".*"=baz').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['~>', 'path', ['foo', 'bar', '.*']], ['=', 'value', 'baz']]]]]
    end

    it 'should handle structured facts with wildcard operator' do
      parser.parse('foo.bar.*=baz').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['~>', 'path', ['foo', 'bar', '.*']], ['=', 'value', 'baz']]]]]
    end

    it 'should handle #node subqueries' do
      parser.parse('#node.catalog_environment=production').should eq ['in', 'certname', ['extract', 'certname', ['select_nodes', ['=', 'catalog_environment', 'production']]]]
    end

    it 'should handle #node subqueries with block of conditions' do
      parser.parse('#node { catalog_environment=production }').should eq ['in', 'certname', ['extract', 'certname', ['select_nodes', ['=', 'catalog_environment', 'production']]]]
    end

    it 'should handle #node subquery combined with fact query' do
      parser.parse('#node.catalog_environment=production and foo=bar').should eq ['and', ['in', 'certname', ['extract', 'certname', ['select_nodes', ['=', 'catalog_environment', 'production']]]], ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['foo']], ['=', 'value', 'bar']]]]]]
    end

    it 'should escape non match parts on structured facts with match operator' do
      parser.parse('"foo.bar".~".*"=baz').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['~>', 'path', ['foo\\.bar', '.*']], ['=', 'value', 'baz']]]]]
    end

    it 'should parse dates in queries' do
      date = Time.new(2014, 9, 9).utc.strftime('%FT%TZ')
      parser.parse('#node.report_timestamp<@"Sep 9, 2014"').should eq ['in', 'certname', ['extract', 'certname', ['select_nodes', ['<', 'report_timestamp', date]]]]
    end

    it 'should not wrap it in a subquery if mode is :none' do
      parser.parse('class[apache]', :none).should eq ["and", ["=", "type", "Class"], ["=", "title", "Apache"], ["=", "exported", false]]
    end
  end

  context 'facts_query' do
    let(:parser) { PuppetDB::Parser.new }
    it 'should return a query for all if no facts are specified' do
      parser.facts_query('kernel=Linux').should eq ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['kernel']], ['=', 'value', 'Linux']]]]]
    end

    it 'should return a query for specific facts if they are specified' do
      parser.facts_query('kernel=Linux', ['ipaddress']). should eq ['and', ['in', 'certname', ['extract', 'certname', ['select_fact_contents', ['and', ['=', 'path', ['kernel']], ['=', 'value', 'Linux']]]]], ['or', ['=', 'name', 'ipaddress']]]
    end

    it 'should return a query for matching facts on all nodes if query is missing' do
      parser.facts_query('', ['ipaddress']).should eq ['or', ['=', 'name', 'ipaddress']]
    end
  end

  context 'facts_hash' do
    let(:parser) { PuppetDB::Parser.new }
    it 'should merge facts into a nested hash' do
      parser.facts_hash([
        { 'certname' => 'ip-172-31-45-32.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'kernel', 'value' => 'Linux' },
        { 'certname' => 'ip-172-31-33-234.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'kernel', 'value' => 'Linux' },
        { 'certname' => 'ip-172-31-5-147.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'kernel', 'value' => 'Linux' },
        { 'certname' => 'ip-172-31-45-32.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'fqdn', 'value' => 'ip-172-31-45-32.eu-west-1.compute.internal' },
        { 'certname' => 'ip-172-31-33-234.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'fqdn', 'value' => 'ip-172-31-33-234.eu-west-1.compute.internal' },
        { 'certname' => 'ip-172-31-5-147.eu-west-1.compute.internal', 'environment' => 'production', 'name' => 'fqdn', 'value' => 'ip-172-31-5-147.eu-west-1.compute.internal' }
      ]).should eq(
        'ip-172-31-45-32.eu-west-1.compute.internal' => { 'kernel' => 'Linux', 'fqdn' => 'ip-172-31-45-32.eu-west-1.compute.internal' },
        'ip-172-31-33-234.eu-west-1.compute.internal' => { 'kernel' => 'Linux', 'fqdn' => 'ip-172-31-33-234.eu-west-1.compute.internal' },
        'ip-172-31-5-147.eu-west-1.compute.internal' => { 'kernel' => 'Linux', 'fqdn' => 'ip-172-31-5-147.eu-west-1.compute.internal' }
      )
    end
  end

  context 'extract' do
    it 'should create an extract query' do
      PuppetDB::ParserHelper.extract(:certname, :name, ['=', 'certname', 'foo.example.com']).should eq(
        ['extract', ['certname', 'name'], ['=', 'certname', 'foo.example.com']]
      )
    end
  end
end
