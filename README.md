[![Build Status](https://travis-ci.org/dalen/puppet-puppetdbquery.png)](https://travis-ci.org/dalen/puppet-puppetdbquery)

PuppetDB query tools
====================

This module implements command line tools and Puppet functions that can be used to query puppetdb.
There's also a hiera backend that can be used to return query results from puppetdb.

Query format
============

The query format accepts resource references in the form:

    Type[Name]{attribute1=foo and attribute2=bar}

Each of the three parts are optional. It will only match non exported resources by default, to match exported resources add @@ in front.

Facts can be matched using the operators =, !=, >, < and ~ (regexp match). > and < only work on numbers, ~ only works on strings.

Any expression can be combined using "not", "and" or "or", in that precedence order. To change precedence you can use parenthesis.

Alphanumeric strings don't need to be quoted, but can be quoted using double quotes with the same escaping rules as JSON.
Numbers are interpreted as numbers and true/false as boolean values, to use them as strings instead simply quote them.

Installation
------------

Ensure that the lib directory is in Ruby's LOADPATH.

     $ export RUBYLIB=puppet-puppetdbquery/lib:$RUBYLIB

PuppetDB terminus is required for the Puppet functions, but not the face.

Usage
======

To get a list of the supported subcommands for the query face, run:

     $ puppet help query

You can run `puppet help` on the returned subcommands

    $ puppet help query nodes
    $ puppet help query facts

CLI
---

Each of the faces uses the following query syntax to return all objects found on a subset of nodes:

    # get all nodes that contain the apache package and are in france, or all nodes in the us
    $ puppet query nodes '(Package[httpd] and country=fr) or country=us'

Each of the individual faces returns a different data format:

nodes - a list of nodes identified by a name

     $ puppet query nodes '(Package["mysql-server"] and architecture=amd64)'
       ["db_node_1", "db_node2"]

facts - a hash of facts per node

     $ puppet query facts '(Package["mysql-server"] and architecture=amd64)'
       db_node_1  {"facterversion":"1.6.9","hostname":"controller",...........}
       db_node_2  {"facterversion":"1.6.9","hostname":"controller",...........}

events - a list of events on the matched nodes

     $ puppet query events '(Package["mysql-server"] and architecture=amd64)' --since='1 hour ago' --until=now --status=success
       host.example.com: 2013-06-10T10:58:37.000Z: File[/foo/bar]/content ({md5}5711edf5f5c50bd7845465471d8d39f0 -> {md5}e485e731570b8370f19a2a40489cc24b): content changed '{md5}5711edf5f5c50bd7845465471d8d39f0' to '{md5}e485e731570b8370f19a2a40489cc24b'

Ruby
----

  faces can be called from the ruby in exactly they same way they are called from the command line:

    $ irb> require 'puppet/face'
      irb> Puppet::Face[:query, :current].nodes('(Package["mysql-server"] and architecture=amd64)')

Puppet functions
----------------

There's corresponding functions to query PuppetDB directly from Puppet manifests.

### query_nodes

Accepts two arguments, a query used to discover nodes, and a optional
fact that should be returned.

Returns an array of certnames or fact values if a fact is specified.

#### Examples

$hosts = query_nodes('manufacturer~"Dell.*" and processorcount=24 and Class[Apache]')

$hostips = query_nodes('manufacturer~"Dell.*" and processorcount=24 and Class[Apache]', ipaddress)

### query_facts

Similar to query_nodes but takes two arguments, the first is a query used to discover nodes, the second is a list of facts to return for those nodes.

Returns a nested hash where the keys are the certnames of the nodes, each containing a hash with facts and fact values.

#### Example

query_facts('Class[Apache]{port=443}', ['osfamily', 'ipaddress'])

Example return value in JSON format:

{
  "foo.example.com": {
    "ipaddress": "192.168.0.2",
    "osfamily": "Redhat"
  },
  "bar.example.com": {
    "ipaddress": "192.168.0.3",
    "osfamily": "Debian"
  }
}

Hiera backend
=============

The hiera backend can be used to return an array with results from a puppetdb query. It requires another hiera backend to be active at the same time, and that will be used to define the actual puppetdb query to be used. It does not matter which backend that is, there can even be several of them. To enable add the backend `puppetdb`to the backends list in `hiera.yaml`.

So instead of writing something like this in for example your `hiera-data/common.yaml`:

    ntp::servers:
      - 'ntp1.example.com'
      - 'ntp2.example.com'

You can now instead write:

    ntp::servers::_nodequery: 'Class[Ntp::Server]'

It will then find all nodes with the class ntp::server and return an array containing their certname. If you instead want to return the value of a fact, for example the `ipaddress`, the nodequery can be a tuple, like:

    ntp::servers::_nodequery: ['Class[Ntp::Server]', 'ipaddress']

or a hash:

    ntp::servers::_nodequery:
      query: 'Class[Ntp::Server]'
      fact: 'ipaddress'

When returning facts only nodes that actually have the fact are returned, even if more nodes would in fact match the query itself.
