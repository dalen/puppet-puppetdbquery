Usage?
======

Query PuppetDB for nodes with the *httpd* package managed in France or any nodes in the US

     $ bin/find-nodes.rb --query "(Package[httpd] and country=fr) or country=us"
