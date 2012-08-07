Puppet Usage
============

This tool implements command line tools that can be used to query puppetdb.


Installation
------------

Ensure that the lib directory is in Ruby's LOADPATH.

     $ export RUBYLIB=ruby-puppetdb/lib:$RUBYLIB

Usage
======

To get a list of the supported subcommands for the query face, run:

     $ puppet help query

You can run `puppet help` on the returned subcommands

    $ puppet help query node
    $ puppet help query fact
    $ puppet help query resource

CLI
---

Each of the faces uses the following query syntax to return all objects found on a subset of nodes:

    # get all nodes that contain the apache package and are in france, or all nodes in the us
    $ puppet query node --query (Package[httpd] and country=fr) or country=us)'

Each of the individual faces returns a different data format:

node - a list of nodes identified by a name

     $ puppet query node --query '(Package[mysql-server] and architecture=amd64)'
       ["db_node_1", "db_node2"]

fact - a hash of facts per node

     $ puppet query fact --query '(Package[mysql-server] and architecture=amd64)'
       db_node_1  {"facterversion":"1.6.9","hostname":"controller",...........}
       db_node_2  {"facterversion":"1.6.9","hostname":"controller",...........}

resource - a hash of resources that contains node membership of each resource

    $ puppet query resource --query '(Package[mysql-server] and architecture=amd64)'

Each of the individual faces also accepts `--filter` which can be used to modified the returned results.

node - by default, it returns the node names of nodes that match the query. The --filter command accepts
a single fact name that can be used to return to represent each node (instead of node name)

    $ puppet query node --query '(Package[mysql-server] and architecture=amd64)' --filter fqdn
      ["db_node_1.mydomain.com", "db_node2.my_domain.com"]

fact - by default, it returns all facts for all nodes that match the query. The --filter option accepts
a ',' delimited list of fact names to return.

    $ puppet query fact --query '(Package[mysql-server] and architecture=amd64)' --filter uptime,architecture
      db_node_1  {"architecture":"amd64","uptime":"0:01 hours"}
      db_node_2  {"architecture":"amd64","uptime":"0:26 hours"}

resource - by default, it returns all resources together with their membership for all nodes. The --filter
accepts a ',' delimited list of resource references that can be used to specify the exact resources to return.

    $ puppet query resource --query '(Package[mysql-server] and architecture=amd64)' --filter Package[mysql-server] --render-as yaml
    14fc9c1fbfa37e93afe9799fd927948b41280764:
      parameters:
        ensure: present
      type: Package
      nodes:
        - db_node_1
        - db_node_2
      title: mysql-server

Each of the types also support the --only-active option.

Ruby
----

  faces can be called from the ruby in exactly they same way they are called from the command line:

    $ irb> require 'puppet/face'
      irb> Puppet::Face[:query, :current].node(:query => '(Package[mysql-server] and architecture=amd64)', :filter => 'fqdn')
