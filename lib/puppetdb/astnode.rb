class PuppetDB::ASTNode
  attr_accessor :type, :value, :children

  def initialize(type, value, children=[])
    @type = type
    @value = value
    @children = children
  end

  # Generate the the query code for a subquery
  #
  # @param from_mode [Symbol] the mode you want to subquery from
  # @param to_mode [Symbol] the mode you want to subquery to
  # @param query the query inside the subquery
  # @return [Array] the resulting subquery
  def subquery(from_mode, to_mode, query)
    return ['in', (from_mode == :nodes) ? 'name' : 'certname',
      ['extract', (to_mode == :nodes) ? 'name' : 'certname',
        ["select-#{to_mode.to_s}", query]]]
  end

  # Go through the AST and optimize boolean expressions into triplets etc
  # Changes the AST in place
  #
  # @return The optimized AST
  def optimize
    case @type
    when :booleanop
      @children.each do |c|
        if c.type == :booleanop and c.value == @value
          c.children.each { |cc| @children << cc }
          @children.delete c
        end
      end
    end
    @children.each { |c| c.optimize }
    return self
  end

  # Evalutate the node and all children
  #
  # @param mode [Symbol] The query mode we are evaluating for
  # @return [Array] the resulting PuppetDB query
  def evaluate(mode = :nodes)
    case @type
    when :booleanop
      return [@value.to_s, *evaluate_children(mode)]
    when :subquery
      return subquery(mode, @value, *evaluate_children(@value))
    when :exp
      case @value
      when :equals      then op = '='
      when :greaterthan then op = '>'
      when :lessthan    then op = '<'
      when :match       then op = '~'
      end

      case mode
      when :nodes,:facts # Do a subquery to match nodes matching the facts
        return subquery(mode, :facts, ['and', ['=', 'name', @children[0].evaluate(mode)], [op, 'value', @children[1].evaluate(mode)]])
      when :resources
        return [op, ['parameter', @children[0].evaluate(mode)], @children[1].evaluate(mode)]
      end
    when :string
      return @value.to_s
    when :number
      return @value
    when :boolean
      return @value
    when :resourcetitle
      return ['=', 'title', @value]
    when :resourcetype
      return ['=', 'type', @value]
    when :resexported
      return ['=', 'exported', @value]
    end
  end

  # Evaluate all children nodes
  #
  # @return [Array] The evaluate results of the children nodes
  def evaluate_children(mode)
    return children.collect { |c| c.evaluate mode }
  end
end
