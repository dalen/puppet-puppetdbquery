#! /usr/bin/env ruby -S rspec

require 'spec_helper'
require 'puppetdb/connection'

describe PuppetDB::Connection do
  context "Query parsing" do
    let(:connection) { PuppetDB::Connection.new }
    it "should handle double quoted strings" do
      connection.parse_query('foo="bar"').should eq(["in", "name", ["extract", "certname", ["select-facts", ["and", ["=", "name", "foo"], ["=", "value", "bar"]]]]])
    end

    it "should handle precedence" do
      connection.parse_query('foo=1 or bar=2 and baz=3').should eq(["or", ["in", "name", ["extract", "certname", ["select-facts", ["and", ["=", "name", "foo"], ["=", "value", 1]]]]], ["and", ["in", "name", ["extract", "certname", ["select-facts", ["and", ["=", "name", "bar"], ["=", "value", 2]]]]], ["in", "name", ["extract", "certname", ["select-facts", ["and", ["=", "name", "baz"], ["=", "value", 3]]]]]]])
    end
  end
end
