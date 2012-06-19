PuppetDB query functions
========================

This module contains query functions for PuppetDB for use from Puppet.
They require the json and rest-client ruby gems and the puppetdb-terminus.

Only queries over HTTPS are supported atm.

Usage
-----

### pdbquery

The first argument is the URL path that should be queried, for
example 'nodes' or 'status/nodes/<nodename>'.
The second argument if supplied if the query parameter, if it is
a string it is assumed to be JSON formatted and sent as is,
anything else is converted to JSON and then sent.

#### Examples

    # Get list of active nodes
    $ret = pdbquery('nodes', ['=', ['node', 'active'], true ])

    # Query status of current node
    $ret2 = pdbquery("status/nodes/${settings::certname}")

### pdbresourcequery

The first argument is the resource query.
Second argument is optional but allows you to specify the item you want
from the returned hash.

#### Examples

    # Return an array of hashes describing all files that are owned by root.
    $ret = pdbresourcequery(['and',['=','type','File'],['=',['parameter','owner'],'root'],])

    # Return an array of host names having those resources
    $ret = pdbresourcequery(['and',['=','type','File'],['=',['parameter','owner'],'root'],], 'certname')

### pdbnodequery

The first argument is the node query.
Second argument is optional but allows you to specify a resource query
that the nodes returned also have to match.

#### Examples

    # Return an array of active nodes with an uptime more than 30 days
    pdbnodequery(['and',['=',['node','active'],true],['>',['fact','uptime_days'],30]])

    # Return an array of active nodes with an uptime more than 30 days and
    # having the class 'apache'
    pdbnodequery(['and',['=',['node','active'],true],['>',['fact','uptime_days'],30]],
      ['and',['=','type','Class'],['=','title','Apache']])"

### pdbfactquery

The first argument is the node to get facts for.
Second argument is optional, if specified only return that specific fact.

#### Examples

    # Get hash of facts for foo.example.com
    pdbfactquery('foo.example.com')
    # Get the uptime fact for foo.example.com
    pdbfactquery('foo.example.com', 'uptime')