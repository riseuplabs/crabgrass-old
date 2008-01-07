=begin

An abstract super class of SqlBuilder and FerretBuilder

=end

class PathFinder::Builder

  def self.find_pages(method, path, options)
    if method == :sql
      builder = PathFinder::SqlBuilder.new(path, options)
    end
    builder.find_pages()
  end

  def self.count_pages(method, path, options)
    if method == :sql
      builder = PathFinder::SqlBuilder.new(path, options)
    end
    builder.count_pages()
  end
  
  # path keyword => number of arguments required for the keyword.
  PATH_KEYWORDS = {
    # boolean
    'or' => 0,
    
    # conditions
    'unread' => 0,
    'pending' => 0,
    'interesting' => 0,
    'attending' => 0,
    'watching' => 0,
    'starred' => 0,
    'stars' => 1,    
    'type' => 1,
    'tag' => 1,
    'name' => 1,
    'changed' => 0,
    'text' => 1,
    
    
    # associations
    'person' => 1,
    'group' => 1,
    'created_by' => 1,
    'not_created_by' => 1,
    
    # date
    'month' => 1,
    'year' => 1,
    'ago' => 2,
    'upcoming' => 0,
    'created_after' => 1,
    'created_before' => 1,
    'starts' => 0,
    'before' => 1,
    'after' => 1,

    # limit
    'limit' => 1,
        
    # sorting
    'ascending' => 1,
    'descending' => 1
#    'recent' => 1,
#    'old' => 1,
    
  }.freeze

  # path keyword => order weight
  # this with a lower weight show up sooner in the path
  PATH_ORDER = {
    'month' => 1,
    'year' => 2,
    'person' => 5,
    'group' => 5,
    'default' => 10,
    'descending' => 20,
    'ascending' => 20,
    'limit' => 21,
    'text' => 100
  }.freeze

  public

  def find_args_hash()
    # overridden by sub classes
  end
  
  #
  # parses path into filters and applies each filter
  #
  def apply_filters_from_path( path )
    filters = parse_filter_path( path )
    filters.each do |filter|
      filter_method = "filter_#{filter[0].gsub('-','_')}"
      args = filter.slice(1..-1) # remove first element.
      self.send(filter_method, *args) if self.respond_to? filter_method
    end
  end

  # parses a page filter path into an array like so...
  # incoming path:
  #   /unread/tag/urgent/person/23/starred
  # array returned:
  #   [ ['unread'], ['tag','urgent'], ['person',23], ['starred'] ]
  # in other words, we identify the key words and their arguments,
  # and split up that path into an array where each element is a different
  # keyword (with its included arguments). 
  
  def self.parse_filter_path(path)
    return PathFinder::ParsedPath.new unless path
    path = path.split('/') if path.instance_of? String
    path = path.reverse
    parsed_path = PathFinder::ParsedPath.new
    while keyword = path.pop
      next unless PATH_KEYWORDS[keyword]
      element = [keyword]
      args = PATH_KEYWORDS[keyword]
      args.times do |i|
        element << path.pop if path.any?
      end
      parsed_path << element
    end
    return parsed_path
  end
  
  def parse_filter_path(path)
    PathFinder::Builder.parse_filter_path( path )
  end
  
  #
  # given a hash search options (like might be returned
  # in params[:search], build a filter path. For example:
  # in:
  #   {"month"=>"6", "pending"=>"true"}
  # out:
  #   /month/6/pending
  #
  def self.build_filter_path(search)
    search = search.sort{|a,b| (PATH_ORDER[a[0]]||PATH_ORDER['default']) <=> (PATH_ORDER[b[0]]||PATH_ORDER['default']) }
    path = ['']
    search.each do |pair|
      key, value = pair
      next unless PATH_KEYWORDS[key]
      if PATH_KEYWORDS[key] == 0
        path << key if value == 'true'
      elsif PATH_KEYWORDS[key] == 1 and value.any?
        path << key
        path << value
      elsif PATH_KEYWORDS[key] == 2 and value.size = 2
        path << key
        path << value[0]
        path << value[1]
      end
    end
    return path.collect{|i|CGI.escape i}.join('/')
  end
  
end

