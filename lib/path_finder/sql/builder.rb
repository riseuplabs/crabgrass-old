# =PathFinder::Sql::Builder
#
# Concrete subclass of PathFinder::Builder
#
# This class generates the SQL and makes the call to find_by_sql.
# It is called from find_by_path in PathFinder::FindByPath
#
# We are currently using Mysql::Builder.

class PathFinder::Sql::Builder < PathFinder::Builder
  
  include PathFinder::Sql::BuilderFilters

  public 
  
  attr_accessor :and_clauses # used to build the current clause of the form (x and x)
  attr_accessor :values      # array of replacement values for the '?' in conditions
  
  # initializes all the arrays for conditions, aliases, clauses and so on
  def initialize(path, options)
    @conditions  = []
    @order       = []
    @aliases     = []
    @tag_count   = 0
    @or_clauses  = []
    @and_clauses = []
    @date_field  = 'created_at'
    @inbox       = options[:inbox]

    # paginating (count required)
    @per_page    = options[:per_page] || SECTION_SIZE
    @page        = options[:page]     || 1
    # limiting   (count not required)
    @limit       = options[:limit]
    @offset      = options[:offset]
    

    @path        = cleanup_path(path)
    @and_clauses << [options[:conditions].dup] if options[:conditions]
    @values      = options[:values] ? options[:values].dup : []
    @flow        = options[:flow]
    @union       = options[:union]
    if @union
      @select  = 'pages.*'
    else
      @select  = 'DISTINCT pages.*'
    end
  end

  def paginate
    Page.paginate_by_sql sql_for_find, :page => @page, :per_page => @per_page
  end

  def find
    Page.find_by_sql sql_for_find
  end

  def count
    @order = nil
    @aliases = nil
    if @union
      @select = 'pages.id'
      page_ids = Page.connection.select_values(sql_for_find)
      page_ids.size
    else
      @select = "count(DISTINCT pages.id)"
      Page.count_by_sql sql_for_find
    end
  end

  # uses @path to construct the sql query:
  # * the filters in PathFinder::Sql::BuilderFilters are applyed and
  #   populate the arrays for conditions, {and,or}_clauses and so on.
  # * a hash of different parameters for the sql clause is constructed
  # * finally the sql query is constructed and returned.
  def sql_for_find
    # parse the path and apply each filter
    apply_filters_from_path( @path )
    
    # get a hash of sql elements we will use to build actual sql
    query = build_query_hash()
    
    # build the actual sql
    sql = []
    if query[:unions]
      unions = query[:unions].collect do |union|
        union_sql = []
        union_sql << "SELECT %s" % query[:select]
        union_sql << "FROM pages"
        union_sql << union[:joins] if union[:joins]
        union_sql << 'WHERE %s' % union[:where] if union[:where]
        union_sql.join(" ")
      end
      sql << unions.join(' UNION ')
    else
      sql << "SELECT %s"   % query[:select]
      sql << "FROM pages"
      sql << query[:joins]                 if query[:joins]
      sql << 'WHERE %s'    % query[:where] if query[:where]
    end

    sql << 'ORDER BY %s' % query[:order] if query[:order]
    if query[:offset]
      sql << 'LIMIT %s, %s' % [query[:offset],query[:limit]]
    elsif query[:limit]
      sql << 'LIMIT %s' % query[:limit]
    end

    # helpful for debuggin tests:
    # puts sql.join("\n")
    
    sql.join("\n")
  end
  
  ######################################################################
  #### PRIVATE
  
  private
  
  # 
  # returns a final hash of query options
  # called only by find_pages
  #
  def build_query_hash()
    # add flow (must come first, because it might alter @conditions)
    add_flow( @flow )

    # grab the remaining open conditions
    @or_clauses << @conditions if @conditions.any?
    @and_clauses << @or_clauses
    @and_clauses.reject!(&:blank?)
         
    # handle order (and any necessary aliases)         
    order = sql_for_order()
    if @aliases.any?
      @select = ([@select] + @aliases).join(', ')
    end

    if @and_clauses.any?
      where = sql_for_where(@and_clauses,@values)
      joins = sql_for_joins(where)
    else
      where = nil
      joins = nil
    end
    
    unions = nil
    if @union
      unions = @union.collect do |union|
        uwhere = sql_for_where(union[:conditions],union[:values])
        ujoins = sql_for_joins(uwhere)
        ujoins = [ujoins,joins].join(' ') if joins
        uwhere = [uwhere,where].join(' AND ') if where
        { :joins => ujoins, :where => uwhere }
      end   
    end
         
    # make the hash
    return {
      :where => where,
      :joins => joins,
      :limit => @limit,
      :offset => @offset,
      :order => order,
      :select => @select,
      :unions => unions
    }
  end

  ##########################################################
  ### UTILITY METHODS (called by build_query_hash)
  
  # convert the query we have built into an actual sql condition  
  # the argument is an array, each element assumed to be a
  # separate AND clause
  def sql_for_conditions(and_clauses)
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
  
  # if the conditions use user or group participations to limit which pages are returned,
  # then we must join in those tables. we don't use :include because we don't want the data,
  # we just want to be able to add conditions to the query. We alias the tables because 
  # user_participations or group_participations might already be included as the main table, so
  # we have to give it a new name.
  
  def sql_for_joins(conditions_string)
    joins = []
    
    # main joins
    if /user_participations\./ =~ conditions_string
      joins << "LEFT OUTER JOIN user_participations ON user_participations.page_id = pages.id"
    end
    if /group_participations\./ =~ conditions_string
      joins << "LEFT OUTER JOIN group_participations ON group_participations.page_id = pages.id"
    end
    
    # alias the participation tables for joins with extra conditions
    # (for use when the main join has already been used)
    if /user_parts\./ =~ conditions_string
      joins << "LEFT OUTER JOIN user_participations user_parts ON user_parts.page_id = pages.id"
    end
    if /group_parts\./ =~ conditions_string
      joins << "LEFT OUTER JOIN group_participations group_parts ON group_parts.page_id = pages.id"
    end
    
    # special named joins for multiple tagging conditions
    for i in 1..4
      if /taggings#{i}\./ =~ conditions_string
        joins << "INNER JOIN taggings taggings#{i} ON (pages.id = taggings#{i}.taggable_id AND taggings#{i}.taggable_type = 'Page')"
      end  
    end

    return joins.join("\n")
  end
  
  def sql_for_order
    return if @order.nil?
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

  def sql_for_where(conditions, values)
    Page.public_sanitize_sql([sql_for_conditions(conditions)] + values )
  end
    
end
