# Helper methods for the parser, included in the parser class
require 'puppetdb'
module PuppetDB::ParserHelper
  # Parse a query string into a PuppetDB query
  #
  # @param query [String] the query string to parse
  # @param endpoint [Symbol] the endpoint for which the query should be evaluated
  # @return [Array] the PuppetDB query
  def parse(query, endpoint = :nodes)
    if query = scan_str(query)
      query.optimize.evaluate endpoint
    end
  end

  # Create a query for facts on nodes matching a query string
  #
  # @param query [String] the query string to parse
  # @param facts [Array] an array of facts to get
  # @return [Array] the PuppetDB query
  def facts_query(query, facts = nil)
    nodequery = parse(query, :facts)
    if facts.nil?
      nodequery
    else
      factquery = ['or', *facts.collect { |f| ['=', 'name', f] }]
      if nodequery
        ['and', nodequery, factquery]
      else
        factquery
      end
    end
  end

  # Turn an array of facts into a hash of nodes containing facts
  #
  # @param facts [Array] fact values
  # @return [Hash] nodes as keys containing a hash of facts as value
  def facts_hash(facts)
    facts.reduce({}) do |ret, fact|
      if ret.include? fact['certname']
        ret[fact['certname']][fact['name']] = fact['value']
      else
        ret[fact['certname']] = { fact['name'] => fact['value'] }
      end
      ret
    end
  end
end
