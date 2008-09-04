=begin

Concrete subclass of Builder

This class uses a fulltext index on page_terms in order to resolve permissions for pages.
This bypasses potentially really hairy four-way joins on user_participations and group_participations tables.
(not to mention a potential 5th,6th,7th joins for tags, ugh!)

An example query:

  SELECT * FROM pages
  JOIN page_terms ON pages.id = page_terms.page_id
  WHERE
    MATCH(page_terms.access_ids)
    AGAINST('+(0001 0011 0081 0082) +0081' IN BOOLEAN MODE)

* this is an inner join, because *every* page should
  have a corresponding page_term.
* page_term.access_ids is a text column with a fulltext index.
  the format of the values in access_ids is thus:
  * user ids are prefixed with 1
  * group ids are prefixed with 8
  * every id is at least four characters in length, 
    padded with zeros if necessary.
  * if page is public, id 0001 is present.

So, suppose the current user was id 1, and they were
members of groups 1 and 2. 

To find all the pages of group 1 that current_user may access:

   (current_user.id OR public OR current_user.all_group_ids) AND group.id

In fulltext boolean mode search on access_ids, this becomes:

   +(0011 0001 0081 0082) +0081

The first part of this condition is called the access_me_clause. This is where we
resolve the question "what does current user have access to?". This clause is
based entirely on the current_user variable.

The next AND clause is called the access_target_clause. This is where we ask "who's
pages are we searching for?". This clause is based entirely on what options
are used (ie options_for_group() or options_for_user())

There can be additional AND clauses. These are called access_filter_clauses.
This is for additional limits that pop up in the path itself. It is based
entirely on what is in the filter path.

=end

class PathFinder::Mysql::Builder < PathFinder::Builder

  include PathFinder::Mysql::BuilderFilters

  public

  def initialize(path, options)

    ## page_terms stuff
    if options[:group_ids] or options[:user_ids] or options[:public]
      @access_me_clause = "+(%s)" % Page.access_ids_for(
        :public    => options[:public],
        :group_ids => options[:group_ids],
        :user_ids  => options[:user_ids]
      ).join(' ')
    end
    if options[:secondary_group_ids] or options[:secondary_user_ids]
      @access_target_clause = "+(%s)" % Page.access_ids_for(
        :group_ids => options[:secondary_group_ids],
        :user_ids  => options[:secondary_user_ids]
      ).join(' ')
    end
    @access_filter_clause = [] # to be used by path filters

    ## page stuff
    @path        = cleanup_path(path)
    @conditions  = []
    @values      = []
    @order       = []
    @tags        = []
    @or_clauses  = []
    @and_clauses = []
    @flow        = options[:flow]
    @date_field  = 'created_at'

    # magic will_paginate paginating (count required)
    @per_page    = options[:per_page]
    @page        = options[:page]
    # limiting   (count not required)
    @limit       = nil
    @offset      = nil

    # parse the path and apply each filter
    apply_filters_from_path( @path )
  end

  def find
    Page.find :all, options_for_find
  end

  def paginate
    @page ||= 1
    @per_page ||= SECTION_SIZE
    Page.paginate options_for_find.merge(:page => @page, :per_page => @per_page)
  end

  def count
    @order = nil
    Page.count options_for_find
  end

  private

  def options_for_find
    conditions = sql_for_conditions
    order      = sql_for_order
    joins      = nil

    fulltext_filter = [
      @access_me_clause, @access_target_clause, @access_filter_clause, @tags
    ].flatten.compact

    if fulltext_filter.any?
      joins = :page_terms
      conditions += " AND MATCH(page_terms.access_ids, page_terms.tags) AGAINST('%s' IN BOOLEAN MODE)" % fulltext_filter.join(' ')
    end

    # make the hash
    return {
      :conditions => conditions,
      :joins => joins,
      :limit => @limit,         # \ manual offset or limit
      :offset => @offset,       # /   
      :order => order
    }
  end

  # the argument is an array, each element assumed to be a
  # separate AND clause, that may be composed of multiple OR clauses.
  # this method unravels the condition tree and converts it to sql.
  def sql_for_boolean_tree(and_clauses)
    # holy crap, i can't believe how ugly this is
    "(" + and_clauses.collect{|or_clause|
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
    
  def sql_for_order
    return nil if @order.nil?
    filter_descending('updated_at') unless @order.any?   
    @order.reject(&:blank?).join(', ')
  end
    
  def add_flow(flow)
    if flow.nil?
      @conditions << 'pages.flow IS NULL'
    elsif flow.instance_of? Symbol
      @conditions << 'pages.flow = ?'
      @values << FLOW[flow]
    elsif flow.instance_of? Array
      cond = []
      flow.each do |f|
        cond << 'pages.flow = ?'
        @values << FLOW[f]
      end
      @conditions << "(" + cond.join(' OR ') + ")"
    end
  end

  def sql_for_conditions()
    add_flow( @flow )
    
    # grab the remaining open clauses
    @or_clauses << @conditions if @conditions.any?
    @and_clauses << @or_clauses
    @and_clauses.reject!(&:blank?)
    Page.public_sanitize_sql( [sql_for_boolean_tree(@and_clauses)] + @values )
  end    
end

