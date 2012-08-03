require 'rubygems'
require 'puppetdb/util'
require 'puppetdb/matcher'
require 'json'
require 'net/http'
require 'net/https'

class PuppetDB
  def find_nodes_matching(host, port, query_string)
    stack = PuppetDB::Matcher.create_callstack(query_string)

    truth_values = []

    return query_puppetdb(host, port, :empty) if stack == []

    stack.each do |exp|
      case exp.keys.first
        when "statement"
          truth_values << query_puppetdb(host, port, parse_statement(exp)).inspect
        when "and"
          truth_values << "&"
        when "or"
          truth_values << "|"
        when "("
          truth_values << "("
        when ")"
          truth_values << ")"
      end
    end

    eval(truth_values.join(" "))
  end

  def parse_statement(statement)
    statement = statement.to_a.flatten.last

    if statement =~ /^([\w:]+)\[(.+)\]$/
      resource_type = $1.capitalize
      resource_name = $2

      # in puppetdb class names are all capitalized but resource named arent
      resource_name = resource_name.split("::").map{|c| c.capitalize}.join("::") if resource_type == "Class"

      return {"resources" => ["and", ["=", "type", resource_type], ["=", "title", resource_name]]}
    elsif statement =~ /^(\w+)\s*=\s*(\w+)$/
      return {"nodes" => ["and" , ["=", ["fact", $1], $2]]}
    end
  end

  def query_puppetdb(host, port, query)
    http = Net::HTTP.new(host, port)
    #http.use_ssl = true
    #http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    if query == :empty

      resp, data = http.get("/nodes", {"accept" => "application/json"})
      return JSON.parse(data)

    else

      type = query.keys.first

      case type
        when "resources"
          resp, data = http.get("/resources?query=%s" % URI.escape(query[type].to_json), {"accept" => "application/json"})
          return JSON.parse(data).map{|f| f["certname"]}
        when "nodes"
          resp, data = http.get("/nodes?query=%s" % URI.escape(query[type].to_json), {"accept" => "application/json"})
          return JSON.parse(data)
      end
    end
  end
end
