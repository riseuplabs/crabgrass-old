# = PathFinder::Mysql::BuilderFilters
# This contains all the filters for the different path elements.
# It gets included from the Builder.
#  

module PathFinder::Mysql::BuilderFilters

  protected

  #--
  #Turning RDoc comments of. This is not commented yet and maybe not
  #necessary either.

  ### TIME AND DATE FILTERS

  # for your health, use this to convert local time to utc
  # the dates in @values should be utc, all other date variables
  # should be local time. 
  #++
  def to_utc(time)  # :nodoc:
    time = time.to_time if time.is_a? Date
    Time.zone.local_to_utc(time)
  end

  def filter_starts
    @date_field = "starts_at"
  end

  def filter_created
    @date_field = "created_at"
  end

  def filter_updated
    @date_field = "updated_at"
  end

  def filter_after(date)
#    if date == 'now'
#      date = Time.now
#    else
#      if date == 'today'
#        date = to_utc(local_now.at_beginning_of_day)
#      else
#        year, month, day = date.split('-')
#        date = to_utc( Time.in_time_zone(year, month, day) )
#      end
#    end
#    @conditions << "pages.#{@date_field} >= ?"
#    @values << date.to_s(:db)
  end

  def filter_before(date)
#    if date == 'now'
#      date = Time.now
#    else
#      year, month, day = date.split('-')
#      date = to_utc Time.in_time_zone(year, month, day)
#    end
#    @conditions << "pages.#{@date_field} <= ?"
#    @values << date.to_s(:db)
  end
  
  def filter_changed
    @conditions << 'pages.updated_at > pages.created_at'
  end
 
  def filter_upcoming
    @conditions << 'pages.starts_at > ?'
    @values << Time.now
    @order << 'pages.starts_at DESC' if @order
  end
  
  def filter_ago(near,far)
    near = near.to_i.days.ago
    far  = far.to_i.days.ago
    @conditions << 'pages.updated_at < ? and pages.updated_at > ? '
    @values << to_utc(near) << to_utc(far)
  end
  
  def filter_created_after(date)
#    year, month, day = date.split('-')
#    date = to_utc Time.in_time_zone(year, month, day)
#    @conditions << 'pages.created_at > ?'
#    @values << date.to_s(:db)
  end
  
  def filter_created_before(date)
#    year, month, day = date.split('-')
#    date = to_utc Time.in_time_zone(year, month, day)
#    @conditions << 'pages.created_at < ?'
#    @values << date.to_s(:db)
  end
 
  #--
  # 2008      --> all pages from 2008-1-1 up to but not including 2009-1-1
  # 2008-12   --> all pages from 2008-12-1 up to but not including 2009-1-1
  # 2008-12-5 --> all pages from 2008-12-5 up to but not including 2008-12-6
  #++
  def filter_date(date)
    start_year, start_month, start_day = date.split('-')
    if start_year.nil?
      return # no way to deal with an empty date
    elsif start_month.nil?
      start_time = Date.new(start_year.to_i, 1, 1)
      end_time = start_time + 1.year
    elsif start_day.nil?
      start_time = Date.new(start_year.to_i, start_month.to_i, 1)
      end_time = start_time + 1.month
    else
      start_time = Date.new(start_year.to_i, start_month.to_i, start_day.to_i)
      end_time = start_time + 1.day
    end
    @conditions << "pages.`#{@date_field}` >= ? AND pages.`#{@date_field}` < ?"
    @values << to_utc(start_time) << to_utc(end_time)
  end
  
  #--
  #### FULLTEXT FILTERS
  #++
    
  def filter_person(id)
    @access_filter_clause << "+" + Page.access_ids_for(
      :user_ids  => [id]
    ).first
  end
  
  def filter_group(id)
    @access_filter_clause << "+" + Page.access_ids_for(
      :group_ids  => [id]
    ).first
  end

  #--
  # TODO: allow multiple OR tags instead of only AND tags
  # ie "+(this_tag or_this_tag)" rather than "+this_tag +and_this_tag"
  # ++
  def filter_tag(tag_name)
    @tags << "+" + Page.searchable_tag_list([tag_name]).first
  end

  #--
  ### OTHER PAGE COLUMNS
  #++

  def filter_type(page_class_group)
    page_class_names = Page.class_group_to_class_names(page_class_group)
    @conditions << 'pages.type IN (?)'
    @values << page_class_names
  end

  def filter_created_by(id)
    @conditions << 'pages.created_by_id = ?'
    @values << id 
  end

  def filter_not_created_by(id)
    @conditions << 'pages.created_by_id != ?'
    @values << id 
  end
    
  def filter_name(name)
    @conditions << 'pages.name = ?'
    @values << name
  end

  #--
  # in case sphinx is not available, but this should really never be used.
  #++
  def filter_text(text)
    @conditions << 'pages.title LIKE ?'
    @values << "%#{text}%"
  end
  
  def filter_stars(star_count)
    @conditions << 'pages.stars >= ?'
    @values << star_count
  end

  def filter_starred
    @conditions << 'pages.stars > 0'
  end

  #--
  #### sorting  ####
  #++
  
  def filter_ascending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "pages.%s ASC" % sortkey
  end
  
  def filter_descending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "pages.%s DESC" % sortkey
  end

  #--
  #### BOOLEAN ####
  #++
  
  def filter_or
    @or_clauses << @conditions
    @conditions = []
  end
  
  #--
  ### LIMIT ###
  #++

  def filter_limit(limit)
    offset = 0
    if limit.instance_of? String 
      limit, offset = limit.split('-')
    end
    @limit = limit.to_i if limit
    @offset = offset.to_i if offset
  end

  def filter_per_page(per_page)
    @page ||= 1
    @per_page = per_page.to_i
  end

  #--
  ## ASSOCIATION
  #++

  def filter_featured_by(group_id)
    @conditions << 'group_participations.group_id = ? AND group_participations.static = TRUE'
    @values << [group_id.to_i]
  end

  def filter_contributed(user_id)
    @conditions << 'user_participations.user_id = ? AND user_participations.changed_at IS NOT NULL'
    @values << [user_id.to_i]
    @order << "user_participations.changed_at DESC" if @order
  end

#turning RDoc comments back on. 
#++ 
end


