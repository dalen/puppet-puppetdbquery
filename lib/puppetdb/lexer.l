# vim: syntax=ruby

require 'json'

class PuppetDB::Lexer
rule
	\s			# whitespace no action
	\(			{ [:LPAREN, text] }
	\)			{ [:RPAREN, text] }
	\[			{ [:LBRACK, text] }
	\]			{ [:RBRACK, text] }
	\{			{ [:LBRACE, text] }
	\}			{ [:RBRACE, text] }
	=			{ [:EQUALS, text] }
	\!=			{ [:NOTEQUALS, text] }
	~			{ [:MATCH, text] }
	<			{ [:LESSTHAN, text] }
	>			{ [:GREATERTHAN, text] }
	not			{ [:NOT, text] }
	and			{ [:AND, text] }
	or			{ [:OR, text] }
	true			{ [:BOOLEAN, true]}
	false			{ [:BOOLEAN, false]}
	-?\d+			{ [:NUMBER, text.to_i] }
	-?\d+\.?(\d+)?		{ [:NUMBER, text.to_f] }
	\"(\\.|[^\\"])*\"	{ [:STRING, JSON.load(text)] }
	[\w_:]+			{ [:STRING, text] }
end
