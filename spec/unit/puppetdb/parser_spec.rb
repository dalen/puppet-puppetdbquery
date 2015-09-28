#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'puppetdb/parser'

describe PuppetDB::Parser do
  context "Query parsing" do
    let(:parser) { PuppetDB::Parser.new }
    it "should handle empty queries" do
      parser.parse('').should be_nil
    end

    it "should handle double quoted strings" do
      parser.parse('foo="bar"').should eq ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "foo"], ["=", "value", "bar"]]]]]
    end

    it "should handle single quoted strings" do
      parser.parse('foo=\'bar\'').should eq ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "foo"], ["=", "value", "bar"]]]]]
    end

    it "should handle precedence" do
      parser.parse('foo=1 or bar=2 and baz=3').should eq ["or", ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "foo"], ["=", "value", 1]]]]], ["and", ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "bar"], ["=", "value", 2]]]]], ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "baz"], ["=", "value", 3]]]]]]]
      parser.parse('(foo=1 or bar=2) and baz=3').should eq ["and", ["or", ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "foo"], ["=", "value", 1]]]]], ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "bar"], ["=", "value", 2]]]]]], ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "baz"], ["=", "value", 3]]]]]]
    end

    it "should parse resource queries with only type name" do
      parser.parse('file').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", "type", "File"]]]]]
    end

    it "should parse resource queries with only title" do
      parser.parse('[foo]').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", "title", "foo"]]]]]
    end

    it "should parse resource queries with only parameters" do
      parser.parse('{foo=bar}').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", ["parameter", "foo"], "bar"]]]]]
    end

    it "should parse resource queries for exported resources" do
      parser.parse('@@file').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", true], ["=", "type", "File"]]]]]
    end

    it "should parse resource queries with type, title and parameters" do
      parser.parse('file[foo]{bar=baz}').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", "type", "File"], ["=", "title", "foo"], ["=", ["parameter", "bar"], "baz"]]]]]
    end

    it "should parse resource queries with tags" do
      parser.parse('file[foo]{tag=baz}').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", "type", "File"], ["=", "title", "foo"], ["=", "tag", "baz"]]]]]
    end

    it "should handle precedence within resource parameter queries" do
      parser.parse('{foo=1 or bar=2 and baz=3}').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["or", ["=", ["parameter", "foo"], 1], ["and", ["=", ["parameter", "bar"], 2], ["=", ["parameter", "baz"], 3]]]]]]]
      parser.parse('{(foo=1 or bar=2) and baz=3}').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["or", ["=", ["parameter", "foo"], 1], ["=", ["parameter", "bar"], 2]], ["=", ["parameter", "baz"], 3]]]]]
    end

    it "should capitalize class names" do
      parser.parse('class[foo::bar]').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["=", "type", "Class"], ["=", "title", "Foo::Bar"]]]]]
    end

    it "should parse resource queries with regeexp title matching" do
      parser.parse('[~foo]').should eq ["in", "certname", ["extract", "certname", ["select_resources", ["and", ["=", "exported", false], ["~", "title", "foo"]]]]]
    end

    it "should be able to negate expressions" do
      parser.parse('not foo=bar').should eq ["not", ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "foo"], ["=", "value", "bar"]]]]]]
    end
  end

  context "facts_query" do
    let(:parser) { PuppetDB::Parser.new }
    it 'should return a query for all if no facts are specified' do
      parser.facts_query('kernel=Linux').should eq ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "kernel"], ["=", "value", "Linux"]]]]]
    end

    it 'should return a query for specific facts if they are specified' do
      parser.facts_query('kernel=Linux', ['ipaddress']). should eq ["and", ["in", "certname", ["extract", "certname", ["select_facts", ["and", ["=", "name", "kernel"], ["=", "value", "Linux"]]]]], ["or", ["=", "name", "ipaddress"]]]
    end

    it 'should return a query for matching facts on all nodes if query is missing' do
      parser.facts_query('', ['ipaddress']).should eq ["or", ["=", "name", "ipaddress"]]
    end
  end

  context 'facts_hash' do
    let(:parser) { PuppetDB::Parser.new }
    it 'should merge facts into a nested hash' do
      parser.facts_hash([
        {"certname"=>"ip-172-31-45-32.eu-west-1.compute.internal", "environment"=>"production", "name"=>"kernel", "value"=>"Linux"},
        {"certname"=>"ip-172-31-33-234.eu-west-1.compute.internal", "environment"=>"production", "name"=>"kernel", "value"=>"Linux"},
        {"certname"=>"ip-172-31-5-147.eu-west-1.compute.internal", "environment"=>"production", "name"=>"kernel", "value"=>"Linux"},
        {"certname"=>"ip-172-31-45-32.eu-west-1.compute.internal", "environment"=>"production", "name"=>"fqdn", "value"=>"ip-172-31-45-32.eu-west-1.compute.internal"},
        {"certname"=>"ip-172-31-33-234.eu-west-1.compute.internal", "environment"=>"production", "name"=>"fqdn", "value"=>"ip-172-31-33-234.eu-west-1.compute.internal"},
        {"certname"=>"ip-172-31-5-147.eu-west-1.compute.internal", "environment"=>"production", "name"=>"fqdn", "value"=>"ip-172-31-5-147.eu-west-1.compute.internal"}
      ]).should eq(
        "ip-172-31-45-32.eu-west-1.compute.internal"=>{"kernel"=>"Linux", "fqdn"=>"ip-172-31-45-32.eu-west-1.compute.internal"},
        "ip-172-31-33-234.eu-west-1.compute.internal"=>{"kernel"=>"Linux", "fqdn"=>"ip-172-31-33-234.eu-west-1.compute.internal"},
        "ip-172-31-5-147.eu-west-1.compute.internal"=>{"kernel"=>"Linux", "fqdn"=>"ip-172-31-5-147.eu-west-1.compute.internal"}
      )
    end
  end
end
