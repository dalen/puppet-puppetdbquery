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
end
