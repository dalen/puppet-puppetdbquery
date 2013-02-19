class PuppetDB::ASTNode
  attr_accessor :type, :value, :children

  def initialize(type, value, children=[])
    @type = type
    @value = value
    @children = children
  end

  def subquery(from_mode, to_mode, query)
    return query if from_mode == to_mode
    return ['in', (from_mode == :nodes) ? 'name' : 'certname',
      ['extract', (to_mode == :nodes) ? 'name' : 'certname',
        ["select-#{to_mode.to_s}", query]]]
  end

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

  def evaluate(mode = :nodes)
    case @type
    when :booleanop
      return [@value.to_s, *evaluate_children(mode)]
    when :subquery
      return subquery(mode, @value, *evaluate_children(@value))
    when :exp
      case @value
      when :equals:      op = '='
      when :greaterthan: op = '>'
      when :lessthan:    op = '<'
      when :match:       op = '~'
      end

      case mode
      when :nodes # we are trying to query for facts but are in node mode, do a subquery
        return subquery(mode, :facts, ['and', ['=', 'name', @children[0].evaluate(mode)], [op, 'value', @children[1].evaluate(mode)]])
      when :facts
        return ['and', ['=', 'name', @children[0].evaluate(mode)], [op, 'value', @children[1].evaluate(mode)]]
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
    end
  end

  def evaluate_children(mode)
    return children.collect { |c| c.evaluate mode }
  end
end
