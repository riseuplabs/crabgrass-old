#=PathFinder::ParsedPath
#A simple class for parsing and generating 'readable url query paths'
#
#Given a path string like so:
#
#   /unread/tag/urgent/person/23/starred
#
#The corresponding ParsedPath would be an array that looks like this:
#
#  [ ['unread'], ['tag','urgent'], ['person',23], ['starred'] ]
#
#To create a ParsedPath, we identify the key words and their arguments, and split
#up that path into an array where each element is a different keyword (with its
#included arguments).
#
#:include:FILTERS
class PathFinder::ParsedPath < Array

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
    'inbox' => 0,
    'starred' => 0,
    'contributed' => 0,
    'stars' => 1,
    'type' => 1,
    'tag' => 1,
    'name' => 1,
    'changed' => 0,
    'text' => 1,
    'most_views' => 2,
    'most_edits' => 2,
    'most_stars' => 2,


    # associations
    'person' => 1,
    'group' => 1,
    'created_by' => 1,
    'not_created_by' => 1,
    'contributed_by' => 1,
    'contributed_group' => 1,
    'featured_by' => 1,
    'admin' => 1,

    # date
    'date' => 1,
    'ago' => 2,
    'upcoming' => 0,
#    'created_after' => 1,
#    'created_before' => 1,
#    'before' => 1,
#    'after' => 1,

    # date field
    'starts' => 0,
    'updated' => 0,
    'created' => 0,

    # limit
    'limit' => 1,

    # sorting
    'ascending' => 1,
    'descending' => 1,
#    'recent' => 1,
#    'old' => 1,

    # pseudo keywords (used to make forms easier)
    # ie {:page_state => 'unread'}
    'page_state' => 1,

    # moderation
    'public' => 0,
    'public_requested' => 0,
    'moderation' => 1
  }.freeze

  # path keyword => order weight
  # things with a lower weight show up sooner in the path
  PATH_ORDER = {
    'started' => 0, # \
    'created' => 0, #  > this come first, because they set @date_field
    'updated' => 0, # /
    'month' => 1,
    'year' => 2,
    'person' => 5,
    'group' => 5,
    'public' => 7,
    'public_requested' => 7,
    'moderation' => 8,
    'default' => 10,
    'descending' => 20,
    'ascending' => 20,
    'limit' => 21,
    'text' => 100
  }.freeze

  def unparsable
    @unparsable ||= []
  end

  # constructs a ParsedPath from a path string, array, or hash
  #
  # Examples:
  #  string --  /unread/tag/urgent --> [['unread'],['tag','urgent']]
  #  array  --  ['person','23','starred'] --> [['person','23'],['starred']]
  #  hash   --  {"month"=>"6", "pending"=>"true"} --> [['month','6'],['pending']]
  #
  # the hash form is used to generate a path from the params from a search form.
  #
  def initialize(path=nil)
    return unless path
    last = nil
    if path.is_a? String or path.is_a? Array
      path = path.split('/') if path.instance_of? String
      last = path.last
      path = path.reverse
      while keyword = path.pop
        if PATH_KEYWORDS[keyword]
          element = [keyword]
          args = PATH_KEYWORDS[keyword]
          args.times do |i|
            element << path.pop if path.any?
          end
          self << element
        else
          self.unparsable << keyword
        end
      end
    elsif path.is_a? Hash
      path = path.sort{|a,b| (PATH_ORDER[a[0]]||PATH_ORDER['default']) <=> (PATH_ORDER[b[0]]||PATH_ORDER['default']) }
      path.each do |pair|
        key, value = pair
        key = key.to_s
        if PATH_KEYWORDS[key]
          if key == 'page_state' and value.any? # handle special pseudo keyword...
            self << [value.to_s]
          elsif PATH_KEYWORDS[key] == 0
            self << [key] if value == 'true'
          elsif PATH_KEYWORDS[key] == 1 and !value.nil? and !value.to_s.empty?
            self << [key, value.to_s]
          elsif PATH_KEYWORDS[key] == 2 and value.size = 2
            self << [key, value[0].to_s, value[1].to_s]
          end
        else
          self.unparsable << key
        end
      end
    end
    # special post processing for some keywords
    self.each do |element|
      if element[0] == 'type'
        element[1].sub!('+', ' ') # trick CGI.escape to encode '+' as '+'.
      end
    end
    if last == 'rss' and unparsable.include?('rss')
      @format = last.to_s
    end
    return self
  end

  #
  # converts a parsed path to a string, suitable for a url.
  #
  def to_path
    '/' + self.flatten.collect{|i|CGI.escape i}.join('/') + (@format || '')
  end
  alias_method :to_s, :to_path     # manual string conversion
  alias_method :to_str, :to_path   # automatic string conversion

  def to_param
    self.flatten + (@format ? [@format] : [])
  end
  def join(char=nil)
    to_param.join(char)
  end

  #
  # generates a string useful for display in the page title
  #
  def title
    self.collect{|segment| segment.join(' ')}.join(' > ')
  end

  # return true if keyword is in the path
  def keyword?(word)
    detect do |e|
      e[0] == word
    end
  end

  # returns the first argument of the pathkeyword
  # if:   path = "/person/23"
  # then: first_arg_for('person') == 23
  def first_arg_for(word)
    element = keyword?(word)
    return nil unless element
    return element[1]
  end
  alias :arg_for :first_arg_for

  # returns first argument of the keyword as an Integer
  # or 0 if the argument is not set
  def int_for(word)
    (arg_for(word)||0).to_i
  end

  # returns the arguments for the keyword
  def args_for(word)
    keyword?(word)
  end

  # returns the search text, if any
  # ie returns "glorious revolution" if path == "/text/glorious+revolution"
  def search_text
    element = keyword? 'text'
    return nil unless element
    return element[1].gsub('+', ' ')
  end

  # returns true if arg is the value for a sort keyword
  # ie sort_arg('created_at') is true if path == /ascending/created_at
  def sort_arg?(arg=nil)
    if arg
      (keyword?('ascending') and first_arg_for('ascending') == arg) or (keyword?('descending') and first_arg_for('descending') == arg)
    else
      keyword?('ascending') or keyword?('descending')
    end
  end

  def sort_by_time?
    sort_arg?('created_at') or sort_arg?('updated_at')
  end


  ##
  ## SETTERS
  ##

  def remove_sort
    self.delete_if{|e| e[0] == 'ascending' or e[0] == 'descending' }
  end

  # adds the sort field, but only if there is none set yet.
  def default_sort(field, direction='descending')
    unless sort_arg?
      self << [direction, field]
    end
    self
  end

  # merge two parsed paths together.
  # for duplicate keywords use the ones in the path_b arg
  def merge(path_b)
    path_b = PathFinder::ParsedPath.new(path_b) unless path_b.is_a? PathFinder::ParsedPath
    path_a = self.dup
    path_a.remove_sort if path_b.sort_arg?
    path_a.replace((path_a + path_b).uniq)
  end

  # same as merge, but replaces self.
  def merge!(path_b)
    path_b = PathFinder::ParsedPath.new(path_b) unless path_b.is_a? PathFinder::ParsedPath
    self.remove_sort if path_b.sort_arg?
    self.concat(path_b).uniq!
    self
  end

  # replace one keyword with another.
  def replace_keyword(keyword, newkeyword, arg1=nil, arg2=nil)
    PathFinder::ParsedPath.new.replace(collect{|elem|
      if elem[0] == keyword
        [newkeyword,arg1,arg2].compact
      else
        elem
      end
    })
  end

  # sets the value of the keyword in the parsed path,
  # replacing existing value or adding to the path as necessary.
  def set_keyword(keyword, arg1=nil, arg2=nil)
    if keyword?(keyword)
      replace_keyword(keyword,keyword,arg1,arg2)
    else
      self << [keyword,arg1,arg2].compact
    end
  end

  # returns a new path with the specified format.
  # if arg is nil, just returns the current format.
  def format(format_type=nil)
    if format_type.nil?
      @format
    else
      path = self.dup
      path.format = format_type
      path
    end
  end
  def format=(value)
    @format = value.to_s
  end
end

