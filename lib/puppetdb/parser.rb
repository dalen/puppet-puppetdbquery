#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.11
# from Racc grammer file "".
#

require 'racc/parser.rb'

require 'puppetdb'
require 'puppetdb/lexer'
require 'puppetdb/astnode'
require 'puppetdb/parser_helper'
module PuppetDB
  class Parser < PuppetDB::Lexer

module_eval(<<'...end grammar.racc/module_eval...', 'grammar.racc', 91)
  include PuppetDB::ParserHelper

...end grammar.racc/module_eval...
##### State transition tables begin ###

racc_action_table = [
     5,    54,    47,    17,    46,    58,    44,    55,    11,    19,
    20,     5,    19,    17,    52,    14,    12,    57,     4,    11,
    17,    16,    17,     5,    15,    33,    14,    12,    17,     4,
    17,    11,    16,    17,     5,    15,    63,    54,    14,    12,
    37,     4,    11,    18,    16,    17,     5,    15,    66,    14,
    12,    54,     4,   nil,    11,    16,    17,     5,    15,   nil,
   nil,    14,    12,    11,     4,    11,    50,    16,    17,   nil,
    15,    12,    14,    12,    65,     4,    16,    17,    16,    17,
   nil,    15,    11,   nil,    19,    20,    11,   nil,    19,    20,
    12,   nil,   nil,    11,    12,    16,    17,   nil,   nil,    16,
    17,    12,   nil,   nil,   nil,   nil,    16,    17,    23,    24,
    21,    22,    27,    28,    25,    26,   nil,   nil,   nil,    30,
    23,    24,    21,    22,    27,    28,    25,    26,   nil,   nil,
   nil,    30 ]

racc_action_check = [
     0,    35,    29,    29,    29,    51,    29,    36,     0,     2,
     2,    20,    39,    44,    35,     0,     0,    47,     0,    20,
    11,     0,     0,    19,     0,     9,    20,    20,    14,    20,
    15,    19,    20,    20,    54,    20,    57,    58,    19,    19,
    18,    19,    54,     1,    19,    19,     4,    19,    62,    54,
    54,    66,    54,   nil,     4,    54,    54,     5,    54,   nil,
   nil,     4,     4,    55,     4,     5,    32,     4,     4,   nil,
     4,    55,     5,     5,    61,     5,    55,    55,     5,     5,
   nil,     5,    30,   nil,    32,    32,    52,   nil,    61,    61,
    30,   nil,   nil,    33,    52,    30,    30,   nil,   nil,    52,
    52,    33,   nil,   nil,   nil,   nil,    33,    33,    59,    59,
    59,    59,    59,    59,    59,    59,   nil,   nil,   nil,    59,
     3,     3,     3,     3,     3,     3,     3,     3,   nil,   nil,
   nil,     3 ]

racc_action_pointer = [
    -2,    43,   -12,   112,    44,    55,   nil,   nil,   nil,    21,
   nil,    -4,   nil,   nil,     4,     6,   nil,   nil,    40,    21,
     9,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   -21,
    72,   nil,    63,    83,   nil,    -5,     3,   nil,   nil,    -9,
   nil,   nil,   nil,   nil,   -11,   nil,   nil,    -2,   nil,   nil,
   nil,     0,    76,   nil,    32,    53,   nil,    13,    31,   100,
   nil,    67,    43,   nil,   nil,   nil,    45,   nil ]

racc_action_default = [
    -2,   -42,    -1,    -3,   -42,   -42,    -8,    -9,   -10,   -25,
   -26,   -42,   -28,   -29,   -42,   -42,   -39,   -40,   -42,   -42,
   -42,   -16,   -17,   -18,   -19,   -20,   -21,   -22,   -23,   -42,
   -42,    -4,   -42,   -42,   -27,   -42,   -42,    68,    -5,    -6,
   -11,   -12,   -13,   -14,   -42,   -24,   -38,   -39,   -25,   -30,
    -7,   -42,   -42,   -32,   -42,   -42,   -15,   -42,   -34,   -42,
   -31,   -42,   -42,   -41,   -35,   -33,   -36,   -37 ]

racc_goto_table = [
     2,    53,    40,    34,    31,    32,    35,    36,    49,    45,
    60,    51,    42,    43,    59,     1,   nil,   nil,   nil,    38,
    39,    41,    48,   nil,    64,    48,   nil,   nil,   nil,   nil,
   nil,   nil,    67,    62,   nil,   nil,    56,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,    48,   nil,   nil,    48,   nil,   nil,
   nil,   nil,   nil,   nil,    61 ]

racc_goto_check = [
     2,    14,     8,     9,     2,     2,     9,     9,    13,     7,
     5,    13,    10,    11,     3,     1,   nil,   nil,   nil,     2,
     2,     9,     9,   nil,    14,     9,   nil,   nil,   nil,   nil,
   nil,   nil,    14,    13,   nil,   nil,     9,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,     9,   nil,   nil,     9,   nil,   nil,
   nil,   nil,   nil,   nil,     2 ]

racc_goto_pointer = [
   nil,    15,     0,   -38,   nil,   -42,   nil,   -20,   -27,    -8,
   -17,   -16,   nil,   -22,   -34 ]

racc_goto_default = [
   nil,   nil,   nil,     3,     6,     7,     8,   nil,   nil,     9,
    10,   nil,    29,    13,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 29, :_reduce_none,
  0, 29, :_reduce_none,
  1, 30, :_reduce_3,
  2, 30, :_reduce_4,
  3, 30, :_reduce_5,
  3, 30, :_reduce_6,
  3, 30, :_reduce_7,
  1, 30, :_reduce_none,
  1, 30, :_reduce_none,
  1, 30, :_reduce_none,
  1, 35, :_reduce_11,
  1, 35, :_reduce_12,
  1, 35, :_reduce_13,
  1, 35, :_reduce_14,
  2, 35, :_reduce_15,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  1, 40, :_reduce_none,
  3, 33, :_reduce_24,
  1, 41, :_reduce_25,
  1, 41, :_reduce_26,
  2, 41, :_reduce_27,
  1, 41, :_reduce_28,
  1, 31, :_reduce_29,
  3, 31, :_reduce_30,
  4, 34, :_reduce_31,
  3, 34, :_reduce_32,
  3, 42, :_reduce_33,
  4, 32, :_reduce_34,
  5, 32, :_reduce_35,
  5, 32, :_reduce_36,
  6, 32, :_reduce_37,
  1, 36, :_reduce_none,
  1, 38, :_reduce_none,
  1, 37, :_reduce_none,
  3, 39, :_reduce_41 ]

racc_reduce_n = 42

racc_shift_n = 68

racc_token_table = {
  false => 0,
  :error => 1,
  :LPAREN => 2,
  :RPAREN => 3,
  :LBRACK => 4,
  :RBRACK => 5,
  :LBRACE => 6,
  :RBRACE => 7,
  :EQUALS => 8,
  :NOTEQUALS => 9,
  :MATCH => 10,
  :NOTMATCH => 11,
  :LESSTHAN => 12,
  :LESSTHANEQ => 13,
  :GREATERTHAN => 14,
  :GREATERTHANEQ => 15,
  :AT => 16,
  :HASH => 17,
  :ASTERISK => 18,
  :DOT => 19,
  :NOT => 20,
  :AND => 21,
  :OR => 22,
  :NUMBER => 23,
  :STRING => 24,
  :BOOLEAN => 25,
  :EXPORTED => 26,
  "@" => 27 }

racc_nt_base = 28

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "LPAREN",
  "RPAREN",
  "LBRACK",
  "RBRACK",
  "LBRACE",
  "RBRACE",
  "EQUALS",
  "NOTEQUALS",
  "MATCH",
  "NOTMATCH",
  "LESSTHAN",
  "LESSTHANEQ",
  "GREATERTHAN",
  "GREATERTHANEQ",
  "AT",
  "HASH",
  "ASTERISK",
  "DOT",
  "NOT",
  "AND",
  "OR",
  "NUMBER",
  "STRING",
  "BOOLEAN",
  "EXPORTED",
  "\"@\"",
  "$start",
  "query",
  "expression",
  "identifier_path",
  "resource_expression",
  "comparison_expression",
  "subquery",
  "literal",
  "boolean",
  "string",
  "integer",
  "float",
  "comparison_op",
  "identifier",
  "block_expression" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

module_eval(<<'.,.,', 'grammar.racc', 27)
  def _reduce_3(val, _values)
     ASTNode.new :regexp_node_match, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 28)
  def _reduce_4(val, _values)
     ASTNode.new :booleanop, :not, [val[1]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 29)
  def _reduce_5(val, _values)
     ASTNode.new :booleanop, :and, [val[0], val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 30)
  def _reduce_6(val, _values)
     ASTNode.new :booleanop, :or, [val[0], val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 31)
  def _reduce_7(val, _values)
     val[1] 
  end
.,.,

# reduce 8 omitted

# reduce 9 omitted

# reduce 10 omitted

module_eval(<<'.,.,', 'grammar.racc', 37)
  def _reduce_11(val, _values)
     ASTNode.new :boolean, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 38)
  def _reduce_12(val, _values)
     ASTNode.new :string, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 39)
  def _reduce_13(val, _values)
     ASTNode.new :number, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 40)
  def _reduce_14(val, _values)
     ASTNode.new :number, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 41)
  def _reduce_15(val, _values)
     ASTNode.new :date, val[1] 
  end
.,.,

# reduce 16 omitted

# reduce 17 omitted

# reduce 18 omitted

# reduce 19 omitted

# reduce 20 omitted

# reduce 21 omitted

# reduce 22 omitted

# reduce 23 omitted

module_eval(<<'.,.,', 'grammar.racc', 54)
  def _reduce_24(val, _values)
     ASTNode.new :comparison, val[1], [val[0], val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 57)
  def _reduce_25(val, _values)
     ASTNode.new :identifier, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 58)
  def _reduce_26(val, _values)
     ASTNode.new :identifier, val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 59)
  def _reduce_27(val, _values)
     ASTNode.new :regexp_identifier, val[1] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 60)
  def _reduce_28(val, _values)
     ASTNode.new :regexp_identifier, '.*' 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 63)
  def _reduce_29(val, _values)
     ASTNode.new :identifier_path, nil, [val[0]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 64)
  def _reduce_30(val, _values)
     val[0].children.push val[2]; val[0] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 67)
  def _reduce_31(val, _values)
     ASTNode.new :subquery, val[1], [val[3]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 68)
  def _reduce_32(val, _values)
     ASTNode.new :subquery, val[1], [val[2]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 71)
  def _reduce_33(val, _values)
     val[1] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 75)
  def _reduce_34(val, _values)
     ASTNode.new :resource, {:type => val[0], :title => val[2], :exported => false} 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 77)
  def _reduce_35(val, _values)
     ASTNode.new :resource, {:type => val[0], :title => val[2], :exported => false}, [val[4]] 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 79)
  def _reduce_36(val, _values)
     ASTNode.new :resource, {:type => val[1], :title => val[3], :exported => true} 
  end
.,.,

module_eval(<<'.,.,', 'grammar.racc', 81)
  def _reduce_37(val, _values)
     ASTNode.new :resource, {:type => val[1], :title => val[3], :exported => true}, [val[5]] 
  end
.,.,

# reduce 38 omitted

# reduce 39 omitted

# reduce 40 omitted

module_eval(<<'.,.,', 'grammar.racc', 86)
  def _reduce_41(val, _values)
     "#{val[0]}.#{val[2]}".to_f 
  end
.,.,

def _reduce_none(val, _values)
  val[0]
end

  end   # class Parser
  end   # module PuppetDB
