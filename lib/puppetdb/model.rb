require 'rgen/metamodel_builder'

module PuppetDB::Model
  extend RGen::MetamodelBuilder::ModuleExtension

  class Expression < RGen::MetamodelBuilder::MMBase
    abstract
  end

  # A Nop - the "no op" expression.
  # @note not really needed since the evaluator can evaluate nil with the meaning of NoOp
  # @todo deprecate? May be useful if there is the need to differentiate between nil and Nop when transforming model.
  #
  class Nop < Expression
  end

  # A binary expression is abstract and has a left and a right expression. The order of evaluation
  # and semantics are determined by the concrete subclass.
  #
  class BinaryExpression < Expression
    abstract
    #
    # @!attribute [rw] left_expr
    #   @return [Expression]
    contains_one_uni 'left_expr', Expression, :lowerBound => 1
    contains_one_uni 'right_expr', Expression, :lowerBound => 1
  end

  # An unary expression is abstract and contains one expression. The semantics are determined by
  # a concrete subclass.
  #
  class UnaryExpression < Expression
    abstract
    contains_one_uni 'expr', Expression, :lowerBound => 1
  end

  # A class that simply evaluates to the contained expression.
  # It is of value in order to preserve user entered parentheses in transformations, and
  # transformations from model to source.
  #
  class ParenthesizedExpression < UnaryExpression; end

  # A boolean not expression, reversing the truth of the unary expr.
  #
  class NotExpression < UnaryExpression; end

  # A comparison expression compares left and right using a comparison operator.
  #
  class ComparisonExpression < BinaryExpression
    has_attr 'operator', RGen::MetamodelBuilder::DataTypes::Enum.new([:'=', :'!=', :'<', :'>', :'<=', :'>=' ]), :lowerBound => 1
  end

  # A match expression matches left and right using a matching operator.
  #
  class MatchExpression < BinaryExpression
    has_attr 'operator', RGen::MetamodelBuilder::DataTypes::Enum.new([:'!~', :'~']), :lowerBound => 1
  end

  # A boolean expression applies a logical connective operator (and, or) to left and right expressions.
  #
  class BooleanExpression < BinaryExpression
    abstract
  end

  # An and expression applies the logical connective operator and to left and right expression
  # and does not evaluate the right expression if the left expression is false.
  #
  class AndExpression < BooleanExpression; end

  # An or expression applies the logical connective operator or to the left and right expression
  # and does not evaluate the right expression if the left expression is true
  #
  class OrExpression < BooleanExpression; end

  # Abstract base class for literals.
  #
  class Literal < Expression
    abstract
  end

  # A literal value is an abstract value holder. The type of the contained value is
  # determined by the concrete subclass.
  #
  class LiteralValue < Literal
    abstract
  end

  # A Literal String
  #
  class LiteralString < LiteralValue
    has_attr 'value', String, :lowerBound => 1
  end

  class LiteralNumber < LiteralValue
    abstract
  end

  # A literal number has a radix of decimal (10), octal (8), or hex (16) to enable string conversion with the input radix.
  # By default, a radix of 10 is used.
  #
  class LiteralInteger < LiteralNumber
    has_attr 'radix', Integer, :lowerBound => 1, :defaultValueLiteral => "10"
    has_attr 'value', Integer, :lowerBound => 1
  end

  class LiteralFloat < LiteralNumber
    has_attr 'value', Float, :lowerBound => 1
  end

  # The DSL `undef`.
  #
  class LiteralUndef < Literal; end

  # DSL `true` or `false`
  class LiteralBoolean < LiteralValue
    has_attr 'value', Boolean, :lowerBound => 1
  end

  class ParameterExpression < Expression
    has_attr 'name', String, :lowerBound => 1
    contains_one_uni 'value', Expression
  end

  class ResourceExpression < Expression
    has_attr 'type', String
    has_attr 'nameexpression', RGen::MetamodelBuilder::DataTypes::Enum.new([ComparisonExpression, MatchExpression])
    has_attr 'parameterexpression', ParameterExpression
  end
end
