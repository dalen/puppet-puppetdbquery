# vim: syntax=ruby


class PuppetDB::Parser

  token LPAREN RPAREN LBRACK RBRACK LBRACE RBRACE
  token EQUALS NOTEQUALS MATCH LESSTHAN GREATERTHAN
  token NOT AND OR
  token NUMBER STRING BOOLEAN

  prechigh
    right NOT
    left  EQUALS MATCH LESSTHAN GREATERTHAN
    left  AND
    left  OR
  preclow

rule
  query: exp

  exp: LPAREN exp RPAREN			{ result = val[1] }
     | NOT exp					{ result = ASTNode.new :booleanop, :not, [val[1]] }
     | exp AND exp				{ result = ASTNode.new :booleanop, :and, [val[0], val[2]] }
     | exp OR exp				{ result = ASTNode.new :booleanop, :or, [val[0], val[2]] }
     | string EQUALS string			{ result = ASTNode.new :exp, :equals, [val[0], val[2]] }
     | string EQUALS boolean			{ result = ASTNode.new :exp, :equals, [val[0], val[2]] }
     | string EQUALS number			{ result = ASTNode.new :exp, :equals, [val[0], val[2]] }
     | string GREATERTHAN number		{ result = ASTNode.new :exp, :greaterthan, [val[0], val[2]] }
     | string LESSTHAN number			{ result = ASTNode.new :exp, :lessthan, [val[0], val[2]] }
     | string MATCH string			{ result = ASTNode.new :exp, :match, [val[0], val[2]] }
     | string NOTEQUALS number			{ result = ASTNode.new :booleanop, :not, [ASTNode.new(:exp, :equals, [val[0], val[2]])] }
     | string NOTEQUALS boolean			{ result = ASTNode.new :booleanop, :not, [ASTNode.new(:exp, :equals, [val[0], val[2]])] }
     | string NOTEQUALS string			{ result = ASTNode.new :booleanop, :not, [ASTNode.new(:exp, :equals, [val[0], val[2]])] }
     | ressubquery

  ressubquery: restype				{ result = ASTNode.new :subquery, :resources, [val[0]] }
             | restitle				{ result = ASTNode.new :subquery, :resources, [val[0]] }
             | resparams			{ result = ASTNode.new :subquery, :resources, [val[0]] }
             | restype restitle			{ result = ASTNode.new :subquery, :resources, [ASTNode.new(:booleanop, :and, [val[0], val[1]])] }
             | restitle resparams		{ result = ASTNode.new :subquery, :resources, [ASTNode.new(:booleanop, :and, [val[0], val[1]])] }
             | restype resparams		{ result = ASTNode.new :subquery, :resources, [ASTNode.new(:booleanop, :and, [val[0], val[1]])] }
             | restype restitle resparams	{ result = ASTNode.new :subquery, :resources, [ASTNode.new(:booleanop, :and, [val[0], val[1], val[2]])] }

  restype: STRING				{ result = ASTNode.new :resourcetype, val[0] }
  restitle: LBRACK STRING RBRACK		{ result = ASTNode.new :resourcetitle, val[1] }
  resparams: LBRACE exp RBRACE			{ result = val[1] }

  string: STRING				{ result = ASTNode.new :string, val[0] }
  number: NUMBER				{ result = ASTNode.new :number, val[0] }
  boolean: BOOLEAN				{ result = ASTNode.new :boolean, val[0] }

end
---- header ----
require 'puppetdb'
require 'puppetdb/lexer'
require 'puppetdb/astnode'

