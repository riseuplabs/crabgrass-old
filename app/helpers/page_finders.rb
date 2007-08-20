#######################################################
# Page Finders
#
# This module includes a bunch of page finding methods
# we want available in all controllers. 
#
# builds conditions for findings pages based on filter path.
# for example: /starred/type/event would search for pages that are starred, of type event.
# order does not matter: the above is equivalent to /type/event/starred
# The actual find might be through the Page, GroupParticipation, or UserParticipation table.
# 


module PageFinders

  private
  
  class QueryBuilder
    attr_accessor :table_class # one of: Page, UserParticipation, GroupParticipation
    attr_accessor :conditions  # the current condition clause we are building
    attr_accessor :values      # array of replacement values for the '?' in conditions
    attr_accessor :order       # the sort order
    attr_accessor :limit       # the sql limit
    attr_accessor :offset      # the sql offset
    attr_accessor :tag_count   # running total of the number of tag conditions
    attr_accessor :or_clauses  # used to build current clause of the form (x or x)
    attr_accessor :and_clauses # used to build the current clause of the form (x and x)
    attr_accessor :date_field
    
    def initialize
      self.table_class = Page
      self.conditions  = []
      self.values      = []
      self.order       = nil
      self.limit       = nil
      self.offset      = nil
      self.tag_count   = 0
      self.or_clauses  = []
      self.and_clauses = []
      self.date_field = 'created_at'
    end

    # grab the remaining open conditions
    def finalize
      or_clauses << conditions if conditions.any? # grab the remaining conditions
      and_clauses << or_clauses
    end
      
    # convert the query we have built into an actual sql condition  
    def sql_for_conditions
      # holy crap, i can't believe how ugly this is
      @sql_string ||= "(" + and_clauses.collect{|or_clause|
        if or_clause.is_a? String
          or_clause
        elsif or_clause.any?
          "(" + or_clause.collect{|condition|
            if condition.is_a? String
              condition
            elsif condition.any?
              condition.join(' AND ')
            end
          }.join(') OR (') + ")"
        else
          "1"
        end
      }.join(') AND (') + ")"
    end
    
    # if the conditions use user or group participations to limit which pages are returned,
    # then we must join in those tables. we don't use :include because we don't want the data,
    # we just want to be able to add conditions to the query. We alias the tables because 
    # user_participations or group_participations might already be included as the main table, so
    # we have to give it a new name.
    
    def sql_for_joins
      conditions_string = self.sql_for_conditions()
      join = ''
      if /user_parts\./ =~ conditions_string
        join += " LEFT OUTER JOIN user_participations user_parts ON user_parts.page_id = pages.id"
      end
      if /group_parts\./ =~ conditions_string
        join += " LEFT OUTER JOIN group_participations group_parts ON group_parts.page_id = pages.id"
      end
      for i in 1..4
        if /taggings#{i}\./ =~ conditions_string
          join += " INNER JOIN taggings taggings#{i} ON (pages.id = taggings#{i}.taggable_id AND taggings#{i}.taggable_type = 'Page')"
        end  
      end
      if table_class == Page and /user_participations\./ =~ conditions_string
        # so we can filter on pages that two users have in common without making the main
        # table be user_participations
        join += " LEFT OUTER JOIN user_participations ON user_participations.page_id = pages.id"
      end
      return join
    end
    
  end
  
  # path keyword => number of arguments required for the keyword.
  PATH_KEYWORDS = {
    # boolean
    'or' => 0,
    
    # conditions
    'unread' => 0,
    'pending' => 0,
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
    
  ###############################################################
  ## FILTERS!!
  
  def filter_unread(qb)
    qb.conditions << 'viewed = ?'
    qb.values << false  
  end
  
  def filter_pending(qb)
    if qb.table_class == UserParticipation
      qb.conditions << 'user_participations.resolved = ?'
    else
      qb.conditions << 'pages.resolved = ?'
    end
    qb.values << false
  end
  
  def filter_starred(qb)
    if qb.table_class == UserParticipation
      qb.conditions << 'user_participations.star = ?'
    else
      qb.conditions << 'user_parts.star = ?'
    end
    qb.values << true
  end
  
  def filter_starts(qb)
    qb.date_field = "starts_at"
  end
  
  def filter_changed(qb)
    qb.conditions << 'pages.updated_at > pages.created_at'
  end
  
  def filter_upcoming(qb)
    qb.conditions << 'pages.starts_at > ?'
    qb.values << Time.now
    qb.order = 'pages.starts_at DESC'
  end
  
  def filter_ago(qb,near,far)
    near = near.to_i.days.ago
    far  = far.to_i.days.ago
    qb.conditions << 'pages.updated_at < ? and pages.updated_at > ? '
    qb.values << near
    qb.values << far
  end
  
  def filter_created_after(qb,date)
    year, month, day = date.split('-')
    date = Time.utc(year, month, day)
    qb.conditions << 'pages.created_at > ?'
    qb.values << date
  end
  
  def filter_created_before(qb,date)
    year, month, day = date.split('-')#path.pop.split('-')
    date = Time.utc(year, month, day)
    qb.conditions << 'pages.created_at < ?'
    qb.values << date
  end
 
  def filter_month(qb,month)
    qb.conditions << "MONTH(pages.#{qb.date_field}) = ?"
    qb.values << month.to_i
  end

  def filter_year(qb,year)
    qb.conditions << "YEAR(pages.#{qb.date_field}) = ?"
    qb.values << year.to_i
  end
  
#  def filter_recent(qb)
#    qb.order = 'pages.updated_at DESC'
#  end
   
#   def filter_old(qb)
#     qb.order = 'pages.updated_at ASC'
#   end

  def filter_type(qb,page_class_group)
    page_classes = Page.class_group_to_class_names(page_class_group)
    qb.conditions << 'pages.type IN (?)'
    qb.values << page_classes
  end
  
  def filter_person(qb,id)
    qb.conditions << 'user_parts.user_id = ?'
    qb.values << id
  end
  
  def filter_group(qb,id)
    qb.conditions << 'group_parts.group_id = ?'
    qb.values << id
  end

  def filter_created_by(qb,id)
    qb.conditions << 'pages.created_by_id = ?'
    qb.values << id 
  end

  def filter_not_created_by(qb,id)
    qb.conditions << 'pages.created_by_id != ?'
    qb.values << id 
  end
  
  def filter_tag(qb,tag_name)
    if tag = Tag.find_by_name(tag_name)
      qb.tag_count += 1
      qb.conditions << "taggings#{qb.tag_count}.tag_id = ?"
      qb.values << tag.id
    else
      qb.conditions << "FALSE"
    end
  end
  
  def filter_name(qb,name)
    qb.conditions << 'pages.name = ?'
    qb.values << name
  end
  
  def filter_ascending(qb,sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    qb.order = "pages.`#{sortkey}` ASC"
  end
  
  def filter_descending(qb,sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    qb.order = "pages.`#{sortkey}` DESC"
  end
  
  def filter_or(qb)
    qb.or_clauses << qb.conditions
    qb.conditions = []
  end
  
  def filter_limit(qb,limit)
    offset = nil
    limit,offset = limit.split('-') if limit.instance_of? Array 
    qb.limit = limit.to_i if limit
    qb.offset = offset.to_i if offset
  end
  
  def filter_text(qb, text)
    qb.conditions << 'pages.title LIKE ?'
    qb.values << "%#{text}%"
  end

  def add_flow(qb, flow)
    if flow.nil?
      qb.conditions << 'pages.flow IS NULL'
    elsif flow.instance_of? Symbol
      qb.conditions << 'pages.flow = ?'
      qb.values << FLOW[flow]
    elsif flow.instance_of? Array
      cond = []
      flow.each do |f|
        cond << 'pages.flow = ?'
        qb.values << FLOW[f]
      end
      qb.conditions << "(" + cond.join(' OR ') + ")"
    end
  end

  public
  
  class ParsedPath < Array
    # return true if keyword is in the path
    def keyword?(word)
      detect do |e|
        e[0] == word
      end
    end
    
    # return the first argument of the pathkeyword
    # if:   path = "/person/23"
    # then: first_arg_for('person') == 23
    def first_arg_for(word)
      element = keyword?(word)
      return nil unless element
      return element[1]
    end
    alias :arg_for :first_arg_for
    
    def int_for(word)
      (arg_for(word)||0).to_i
    end
    
    def args_for(word)
      keyword?(word)
    end
    
    # returns true if arg is the value for a sort keyword
    # ie sort_arg('created_at') is true if path == /ascending/created_at
    def sort_arg?(arg)
      (keyword?('ascending') and first_arg_for('ascending') == arg) or (keyword?('descending') and first_arg_for('descending') == arg)
    end
    
    def remove_sort
      self.delete_if{|e| e[0] == 'ascending' or e[0] == 'descending' }
    end
    
    # converts this parsed path into a string path
    def to_s
      self.flatten.join('/')
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
  
  def parse_filter_path(path)
    return ParsedPath.new unless path
    path = path.split('/') if path.instance_of? String
    path = path.reverse
    parsed_path = ParsedPath.new
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
  
  #
  # given a hash search options (like might be returned
  # in params[:search], build a filter path. For example:
  # in:
  #   {"month"=>"6", "pending"=>"true"}
  # out:
  #   /month/6/pending
  #
  def build_filter_path(search)
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
    path.join('/')
  end
  
  # returns a hash of options (conditions, joins, sorts, etc),
  # that can be sent to ActiveRecord.find.
  # in particular, this function adds the correct options
  # based on the filter path (if set).
  def page_query_from_filter_path(options={})    
    if path = options[:path]
      path = path.split('/') if path.is_a? String
      path = path if path.is_a? Array
    end

    qb = QueryBuilder.new()        
    qb.table_class = options[:class] if options[:class]
    qb.and_clauses << [options[:conditions]]
    qb.values      = options[:values]
    qb.order       = options[:order] || 'pages.updated_at DESC'
    
    filters = parse_filter_path( path )
    filters.each do |filter|
      filter_method = "filter_#{filter[0].gsub('-','_')}"
      args = filter.slice(1..-1) # remove first element.
      self.send(filter_method, qb, *args)
    end    
    add_flow(qb, options[:flow])
    
    qb.finalize
    return {
      :conditions => [qb.sql_for_conditions] + qb.values,
      :joins => qb.sql_for_joins,
      :limit => qb.limit,
      :order => qb.order,
      :class => qb.table_class, 
      :already_built => true
    }
  end
  
  #
  # find_and_paginate_pages()
  # this is the wiz-bang main function for finding and paginating pages
  # see find_pages() if you don't need to paginate.
  # 
  # the options passed in are different than for a normal rails find.
  # see page_query_from_filter_path() for how the options are built.
  # 
  # executes the actual find based on the output of page_query_from_filter_path.
  # 
  # ok, i admit, this is a little complicated:
  # 
  # 1) in order for pagination to work, we need to grab a count of how many records
  #    we are fetching. this is usually done by running a count query, and then
  #    using that count information to run a smaller data query.
  #    
  # 2) however, we want to use eager loading to pull in the participation and pages
  #    in one query using joins. this creates a query with multiple rows for every Page
  #    object. 
  #    
  # 3) this means that we need two counts: one for the number of rows returned, and one
  #    for the number of pages returned. they are different numbers. the rows count is
  #    used for the limit on the data query, and the pages count is used to paginate. 
  #    
  # 4) for this to work, when finding the two counts we need to sort by, group by, and count
  #    the main table id (ie either group_participations.id or user_participations.id).
  #    By doing this, we can run one count query which will tell us the number of pages
  #    (which will be equal to the number of rows in our count query), and the number of
  #    rows that will be returned in the data query (the sum of each value returned in
  #    our count query). 
  # 
  # one more note: to add to the confusion, we are paginating pages, so the term page is
  # ambiguous. it could mean a Page from the pages table, or it could mean a page of things
  # when paginating. i have tried to use the term 'section' instead of a page for the latter.
  # 
  # also, because we are pagination, we need to take a slice (that pertains to the current section)
  # of the counts returned. the idea is the same, but the sort order becomes more important
  # (the count query and data query need to have the same sort)
  # 
  # how much slower is this? i don't know. the extra overhead is in sorting the count query and
  # grouping the count query. i don't think that this will take much longer than a normal count query.
  # 
  def find_and_paginate_pages(options, path=nil)
    options[:path] ||= path
    options = page_query_from_filter_path(options) unless options[:already_built]
    pages_per_section = options[:section_size] || ::SECTION_SIZE
    current_section   = (params[:section] || 1).to_i
    klass      = options[:class]
    main_table = klass.to_s.underscore + "s"
    offset     = (current_section - 1) * pages_per_section
    order      = options[:order] + ", #{main_table}.id"
    
    if klass == Page
      options[:include] = nil
      count_join = ''
      count_distinct = "DISTINCT"
      options[:select] = 'DISTINCT pages.*'
    else
      options[:include] = :page
      count_join = "LEFT OUTER JOIN pages ON pages.id = #{main_table}.page_id "
      count_distinct = ""
      options[:select] = nil
    end

    # we have to build our own count query because rails finder does
    # not have the ability to do DISTINCT
    sql_conditions = ActiveRecord::Base.public_sanitize_sql(options[:conditions])
    sql  = "SELECT count(#{count_distinct} #{main_table}.id) FROM #{main_table} "
    sql += "#{count_join} #{options[:joins]} "
    sql += "WHERE #{sql_conditions} "
    sql += "GROUP BY #{main_table}.id "
    sql += "ORDER BY #{order} "
    sql += "LIMIT #{options[:limit]} "  if options[:limit]
    sql += "OFFSET #{options[:offset]} "  if options[:offset]
    

    counts = klass.connection.select_values(sql)
    #logger.error "counts:\n#{counts.inspect}"
    #logger.error "counts for this section:\n#{counts.slice(offset,pages_per_section).inspect}"
    #logger.error "counts before this section:\n#{counts.slice(0, offset).inspect}"

    total_page_count     = counts.size
    return total_page_count if options[:count_only]
    section_row_count    = counts.slice(offset, pages_per_section).inject(0){|sum, n| sum + n.to_i }
    section_starting_row = counts.slice(0     , offset           ).inject(0){|sum, n| sum + n.to_i }
        
    page_sections = ActionController::Pagination::Paginator.new self, total_page_count, pages_per_section, current_section
    pages = klass.find(:all,
      :conditions => options[:conditions],
      :joins      => options[:joins],
      :order      => options[:order] + ", #{main_table}.id",
      :include    => options[:include],
      :select     => options[:select],
      :limit      => section_row_count,
      :offset     => section_starting_row
    )
    return([pages, page_sections])
  end
  
  def count_pages(options, path=nil)
    options[:path] ||= path
    options = page_query_from_filter_path(options)
    options[:count_only] = true
    return find_and_paginate_pages(options,path)
  end
  
  # a convenience function to find pages using 
  # page_query_from_filter_path style options.
  def find_pages(options, path=nil)
    options[:path] ||= path
    options = page_query_from_filter_path(options) unless options[:already_built]
    if options[:limit]
      # limit is not compatible with find_pages
      pages, page_sections = find_and_paginate_pages(options,path)
      return pages
    end
    klass         = options[:class]
    main_table    = klass.to_s.underscore + "s"
    
    if klass == Page
      options[:include] = nil
      options[:select] = 'DISTINCT pages.*'
    else
      options[:include] = :page
      options[:select] = nil
    end
    
    klass.find(:all,
      :conditions => options[:conditions],
      :joins      => options[:joins],
      :order      => options[:order] + ", #{main_table}.id",
      :limit      => options[:limit],
      :offset     => options[:offset],
      :include    => options[:include],
      :select     => options[:select]
    )
  end
  
  ###########################################################
  # option macros: used to set up the options for path finders
  #
  
  def options_for_me(*args)
    if args.include?(:public)
      { :class      => Page,
        :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)",
        :values     => [current_user.all_group_ids, current_user.id, true] }
    else
      { :class      => Page,
        :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ?)",
        :values     => [current_user.all_group_ids, current_user.id] }    
    end
  end
  
#   def options_for_pages_created_by(user, options={})
#     { :class      => Page,
#       :conditions => "pages.created_by_id = ?",
#       :values     => user.id}.merge(options)
#   end

#   def options_for_pages_not_created_by(user, options={})
#     { :class      => Page,
#       :conditions => "pages.created_by_id != ?",
#       :values     => user.id}.merge(options)
#   end
  
  def options_for_pages_viewable_by(user, options={})
    { :class      => Page,
      :conditions => "(group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)",
      :values     => [user.all_group_ids, user.id, true] }.merge(options)
  end
  
  def options_for_public_pages
    { :class      => Page,
      :conditions => "(pages.public = ?)",
      :values     => [true] }
  end
  
  def options_for_page_participation_by(user)
    options = {:class => Page}
    if logged_in?
      # the person's pages that we also have access to
      options[:conditions] = "user_participations.user_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?)"
      options[:values]     = [user.id, current_user.all_group_ids, current_user.id, true]
    else
      # the person's public pages
      options[:conditions] = "user_participations.user_id = ? AND pages.public = ?"
      options[:values]     = [user.id, true]
    end
    options
  end

  def options_for_group(group, default={})
    options = {:class => GroupParticipation}
    if logged_in?
      # the group's pages that current_useralso has access to
      # this means: the group must have a group participation and one of the following
      # must be true... the page is public, we have a user participation for it, or a group
      # that we are a member of has a group participation for the page.
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [group.id, current_user.all_group_ids, current_user.id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [group.id, true]
    end
    options.merge(default)
  end

end
