PuppetDB query tools
====================

This module implements command line tools and Puppet functions that can be used to query puppetdb.


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
    $ puppet query nodes (Package[httpd] and country=fr) or country=us)'

Each of the individual faces returns a different data format:

nodes - a list of nodes identified by a name

     $ puppet query nodes '(Package["mysql-server"] and architecture=amd64)'
       ["db_node_1", "db_node2"]

facts - a hash of facts per node

     $ puppet query facts '(Package["mysql-server"] and architecture=amd64)'
       db_node_1  {"facterversion":"1.6.9","hostname":"controller",...........}
       db_node_2  {"facterversion":"1.6.9","hostname":"controller",...........}

Ruby
----

  faces can be called from the ruby in exactly they same way they are called from the command line:

    $ irb> require 'puppet/face'
      irb> Puppet::Face[:query, :current].nodes(:query => '(Package["mysql-server"] and architecture=amd64)')

Deprecated PuppetDB query functions
===================================

This module also contains some older deprecated functions that use the raw
version 1 PuppetDB API.
They require the json ruby gem and the puppetdb-terminus.

Only queries over HTTPS are supported atm.

Usage
-----

### pdbresourcequery

The first argument is the resource query.
Second argument is optional but allows you to specify the item you want
from the returned hash.

It automatically excludes deactivated hosts.

Returns an array of hashes or array of strings if second argument is provided.

#### Examples

    # Return an array of hashes describing all files that are owned by root on active hosts.
    $ret = pdbresourcequery(
      ['and',
        ['=','type','File'],
        ['=',['parameter','owner'],'root']])

    # Return an array of host names having those resources
    $ret = pdbresourcequery(
      ['and',
        ['=',['node','active'],true],
        ['=','type','File'],
        ['=',['parameter','owner'],'root']], 'certname')

### pdbresourcequery_all

Works exactly like pdbresourcequery but also returns deactivated hosts.

### pdbnodequery

The first argument is the node query.
Second argument is optional but allows you to specify a resource query
that the nodes returned also have to match.

It automatically excludes deactivated hosts.

Returns a array of strings with the certname of the nodes (fqdn by default).

#### Examples

    # Return an array of active nodes with an uptime more than 30 days
    $ret = pdbnodequery(['>',['fact','uptime_days'],30])

    # Return an array of active nodes with an uptime more than 30 days and
    # having the class 'apache'
    $ret = pdbnodequery(
      ['>',['fact','uptime_days'],30],
      ['and',
        ['=','type','Class'],
        ['=','title','Apache']])

### pdbnodequery_all

Works exactly like pdbnodequery but also returns deactivated hosts.

### pdbfactquery

The first argument is the node to get facts for. It can be either a single node
or an array of nodes. If it is an array the return value of the function will also
be an array.
Second argument is optional, if specified only return that specific fact.

#### Examples

    # Get hash of facts for foo.example.com
    pdbfactquery('foo.example.com')
    # Get the uptime fact for foo.example.com
    pdbfactquery('foo.example.com', 'uptime')
    # Get the uptime fact for foo.example.com and bar.example.com
    pdbfactquery(['foo.example.com', 'bar.example.com'], 'uptime')

### pdbstatusquery

The first argument is the node to get the status for.
Second argument is optional, if specified only return that specific bit of
status, one of 'name', 'deactivated', 'catalog_timestamp' and 'facts_timestamp'.

Returns an array of hashes or a array of strings if second argument is supplied.

#### Examples

    # Get status for foo.example.com
    pdbstatusquery('foo.example.com')
    # Get catalog_timestamp for foo.example.com
    pdbstatusquery('foo.example.com', 'catalog_timestamp')

### pdbquery

This is the generic query function that the others make use of, you probably
don't have to use it and can use one of the specific functions below instead.

The first argument is the URL path that should be queried, for
example 'nodes' or 'status/nodes/<nodename>'.
The second argument if supplied if the query parameter, if it is
a string it is assumed to be JSON formatted and sent as is,
anything else is converted to JSON and then sent.

#### Examples

    # Get list of all active nodes
    $ret = pdbquery('nodes', ['=', ['node', 'active'], true ])

    # Query status of current node
    $ret2 = pdbquery("status/nodes/${settings::certname}")

See [http://docs.puppetlabs.com/puppetdb](http://docs.puppetlabs.com/puppetdb) for
more info and examples about the PuppetDB API.
