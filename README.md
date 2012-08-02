Usage?
======

Query PuppetDB for nodes with the *httpd* package managed in France or any nodes in the US

CLI
---

     $ bin/find-nodes.rb --query "(Package[httpd] and country=fr) or country=us"

Ruby
----

     require 'puppetdb'
     require 'pp'

     pdb = PuppetDB.new
     pp pdb.find_nodes_matching("puppetdb", 443, "(Package[httpd] and country=fr) or country=us")


