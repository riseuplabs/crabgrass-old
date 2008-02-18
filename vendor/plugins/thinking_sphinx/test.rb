require 'optparse'
require 'lib/riddle/client'
require 'lib/riddle/client/filter'
require 'lib/riddle/client/message'
require 'lib/riddle/client/response'

client = Riddle::Client.new("localhost", 3312)
index  = '*'
client.weights = [100, 1]

OptionParser.new do |opts|
  opts.banner = "Usage: test.rb [options]"
  
  opts.on("-h HOST", "--host HOST",
    "Connect to searchd at this host") do |host|
    client.server = host
  end
  
  opts.on("-p PORT", "--port PORT", Integer,
    "Connect to searchd at this port") do |port|
    client.port = port
  end
  
  opts.on("-i INDEX", "--index INDEX",
    "Search through specified indexes") do |idx|
    index = idx
  end
  
  client.sort_by = ""
  opts.on("-s EXPR", "--sortby EXPR",
    "Sort matches by EXPR") do |expr|
    client.sort_by    = expr
    client.sort_mode  = :extended
  end
  
  client.match_mode = :all
  opts.on("-a", "--any", "Use 'match any word' matching mode") do |a|
    client.match_mode = :any
  end
  
  opts.on("-b", "--boolean", "Use 'boolean query' matching mode") do |b|
    client.match_mode = :boolean
  end
  
  opts.on("-e", "--extended", "Use 'extended query' matching mode") do |e|
    client.match_mode = :extended
  end
  
  filter_attr = nil
  opts.on("-f ATTR", "--filter ATTR",
    "Filter by attribute ATTR (default is 'group_id')") do |attrb|
    filter_attr = attrb
  end
  
  filters = []
  opts.on("-v VAL", "--value VAL", Integer,
    "Add VAL to allowed attribute filter list") do |value|
    filters << value
  end
  
  unless filters.empty?
    client.filters << ThinkingSphinx::Client::Filter.new(filter_attr, filters)
  end
  
  client.group_by = ""
  opts.on("-g EXPR", "--groupby EXPR", "Group matches by EXPR") do |expr|
    client.group_by = expr
    client.group_function = :attr
  end
  
  opts.on("-gs EXPR", "--groupsort EXPR", "Sort groups by EXPR") do |expr|
    client.group_clause = expr
  end
  
  opts.on("-d ATTR", "--distinct ATTR",
    "Count distinct values of ATTR") do |attr|
    #
  end
end.parse!

str = ARGV.join(" ")

begin
  results = client.query(str, index)
  puts "Query '#{str}' retrieved #{results[:total]} of #{results[:total_found]} matches in #{results[:time]} sec."
  puts "Query stats:"
  results[:words].each do |word,data|
    puts "    '#{word}' found #{data[:hits]} times in #{data[:docs]} documents"
  end
  puts ""
  
  puts "Matches:"
  results[:matches].each_with_index do |hash, id|
    print "#{id+1}. doc_id=#{hash[:doc]}, weight=#{hash[:weight]}"
    results[:attributes].each do |name,type|
      if type == Riddle::Client::AttributeTypes[:timestamp]
        print ", #{name}=#{ Time.at(hash[:attributes][name]) }"
      else
        print ", #{name}=(#{ Array(hash[:attributes][name]).join(",") })"
      end
    end
    puts ""
  end
rescue Riddle::VersionError, Riddle::ResponseError => err
  puts "Query failed: #{err}."
end