# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageUrlHelper
  
  before_filter :login_required, :breadcrumbs
    
  # rails lazy loading does work well with namespaced classes, so we help it along: 
  def get_tool_class(tool_class_str)
    klass = Module
    tool_class_str.split('::').each do |const|
       klass = klass.const_get(const)
    end
    unless klass.superclass == Page
      raise Exception.new('page type is not a subclass of page')
    else
      return klass
    end
  end

  # returns a string representation of page class based on the tool_type.
  # if the result in ambiguous, all matching classes are returned as an array.
  # for example:
  #   'poll/rate many' returns 'Tool::RateMany'
  #   'poll'           returns ['Tool::RateOne', 'Tool::RateMany']
  def tool_class_str(tool_type)
    ary = TOOLS.collect{|tool_class| tool_class.to_s if (tool_class.tool_type.starts_with?(tool_type) and not tool_class.internal?)}.compact
    return ary.first if ary.length == 1
    return ary
  end
  
  # override standard url_for to cache the result.
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= super(options))
  #end

  # a one stop shopping function for flash messages
  def message(opts)    
    if opts[:success]
      flash[:notice] = opts[:success]
    elsif opts[:error]
      if opts[:later]
        flash[:error] = opts[:error]
      else
        flash.now[:error] = opts[:error]
      end
    elsif opts[:object]
      object = opts[:object]
      unless object.errors.empty?
        flash.now[:error] = _("Changes could not be saved.")
        flash.now[:text] ||= ""
        flash.now[:text] += content_tag "p", _("There are problems with the following fields") + ":"
        flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
        flash.now[:errors] = object.errors
      end
    end
  end
  
  def content_tag(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
  
  protected
  
  # to be written by controllers that display pages
  # called before breadcrumbs
  def fetch_page; end 
  
  # a before filter to override by controllers
  def breadcrumbs; end
  
  def add_crumb(crumb_text,crumb_url)
    @breadcrumbs ||= []
    @breadcrumbs << [crumb_text,crumb_url]
  end
  
  # builds conditions for findings pages based on filter path.
  # for example: /starred/type/event would search for pages that are starred, of type event.
  # order does not matter: the above is equivalent to /type/event/starred
  # The actual find might be through the Page, GroupParticipation, or UserParticipation table.
  # 
  def page_query_from_filter_path(options={})
    klass      = options[:class]
    path       = options[:path]
    conditions = [options[:conditions]]
    values     = options[:values]
    
    # filters
    while folder = path.pop
      if folder == 'unread'
        conditions << 'viewed = ?'
        values << false
      elsif folder == 'pending'
        if klass == UserParticipation
          conditions << 'user_participations.resolved = ?'
        else
          conditions << 'pages.resolved = ?'
        end
        values << false
      elsif folder == 'starred'
        if klass == UserParticipation
          conditions << 'user_participations.star = ?'
        else
          conditions << 'user_parts.star = ?'
        end
        values << true
      elsif folder == 'upcoming'
        conditions << 'pages.happens_at > ?'
        values << Time.now
        order = 'pages.happens_at DESC'
      elsif folder == 'ago'
        near = path.pop.to_i.days.ago
        far  = path.pop.to_i.days.ago
        conditions << 'pages.updated_at < ? and pages.updated_at > ? '
        values << near
        values << far
      elsif folder == 'recent'
        order = 'pages.updated_at DESC'
      elsif folder == 'old'
        order = 'pages.updated_at ASC'
      elsif folder == 'type'
        page_class = tool_class_str(path.pop)
        conditions << 'pages.type IN (?)'
        values << page_class
      elsif folder == 'person'
        conditions << 'user_parts.user_id = ?'
        values << path.pop
      elsif folder == 'group'
        conditions << 'group_parts.group_id = ?'
        values << path.pop
      #elsif folder == 'ascending' or folder == 'descending'
      #  sortkey = path.pop
      #  order = 'pages.updated_at' if sortkey == 'updated'
      #  order = 'sortkey == 'person'
      end
    end

    # default sort
    order ||= 'pages.updated_at DESC'
    
    # add in join tables:
    # if the conditions use user or group participations to limit which pages are returned,
    # then we must join in those tables. we don't use :include because we don't want the data,
    # we just want to be able to add conditions to the query. We alias the tables because 
    # user_participations or group_participations might already be included as the main table, so
    # we have to give it a new name.
    conditions_string = conditions.join(' AND ')
    join = ''
    if /user_parts\./ =~ conditions_string
      join += " LEFT OUTER JOIN user_participations user_parts ON user_parts.page_id = pages.id"
    end
    if /group_parts\./ =~ conditions_string
      join += " LEFT OUTER JOIN group_participations group_parts ON group_parts.page_id = pages.id"
    end
    
    { :conditions => [conditions_string] + values,
      :joins => join, :order => order, :class => klass }
  end
  
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
  def find_and_paginate_pages(options)
    pages_per_section = 30
    current_section   = (params[:section] || 1).to_i
    klass      = options[:class]
    main_table = klass.to_s.underscore + "s"
    offset     = (current_section - 1) * pages_per_section
    order      = options[:order] + ", #{main_table}.id"
    
    unless klass == Page
      options[:include] = :page
      count_join = "LEFT OUTER JOIN pages ON pages.id = #{main_table}.page_id "
    else
      options[:include] = nil
      count_join = ''
    end

    sql_conditions = klass.public_sanitize_sql(options[:conditions])
    sql  = "SELECT count(#{main_table}.id) FROM #{main_table} "
    sql += "#{count_join} #{options[:joins]} "
    sql += "WHERE #{sql_conditions} "
    sql += "GROUP BY #{main_table}.id "
    sql += "ORDER BY #{order}"

    counts = klass.connection.select_values(sql)
    #logger.error "counts:\n#{counts.inspect}"
    #logger.error "counts for this section:\n#{counts.slice(offset,pages_per_section).inspect}"
    #logger.error "counts before this section:\n#{counts.slice(0, offset).inspect}"

    total_page_count     = counts.size
    section_row_count    = counts.slice(offset, pages_per_section).inject(0){|sum, n| sum + n.to_i }
    section_starting_row = counts.slice(0     , offset           ).inject(0){|sum, n| sum + n.to_i }
        
    page_sections = Paginator.new self, total_page_count, pages_per_section, current_section
    pages = klass.find(:all,
      :conditions => options[:conditions],
      :joins      => options[:joins],
      :order      => options[:order] + ", #{main_table}.id",
      :include    => options[:include],
      :limit      => section_row_count,
      :offset     => section_starting_row
    )
    return([pages, page_sections])
  end
  
end
