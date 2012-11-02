#!/usr/bin/ruby

require 'puppet'
require 'puppetdb'
require 'optparse'
require 'pp'

options = {:puppetdb_host => "puppet",
           :puppetdb_port => 443,
           :query => nil}

opt = OptionParser.new

opt.on("--puppetdb [PUPPETDB]", "-p", "Host running PuppetDB (#{options[:puppetdb_host]})") do |v|
  options[:puppetdb_host] = v
end

opt.on("--port [PORT]", "-P", Integer, "Port PuppetDB is running on (#{options[:puppetdb_port]})") do |v|
  options[:puppetdb_port] = v
end

opt.on("--query [QUERY]", "-q", "Query String") do |v|
  options[:query] = v
end

opt.parse!

abort "Please specify a query" unless options[:query]

p = PuppetDB.new
pp p.find_nodes_matching(options[:puppetdb_host], options[:puppetdb_port], options[:query])
