#require 'path_finder/mysql/builder'

module PathFinder::Mysql::BuilderFilters

  protected


  ### TIME AND DATE FILTERS
  
  def filter_starts
    @date_field = "starts_at"
  end

  def filter_after(date)
    if date == 'now'
      date = Time.now
    else
      if date == 'today'
        date = to_utc(local_now.at_beginning_of_day)
      else
        year, month, day = date.split('-')
        date = to_utc( Time.in_time_zone(year, month, day) )
      end
    end
    @conditions << "pages.#{@date_field} >= ?"
    @values << date.to_s(:db)
  end

  def filter_before(date)
    if date == 'now'
      date = Time.now
    else
      year, month, day = date.split('-')
      date = to_utc Time.in_time_zone(year, month, day)
    end
    @conditions << "pages.#{@date_field} <= ?"
    @values << date.to_s(:db)
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
    @values << near
    @values << far
  end
  
  def filter_created_after(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @conditions << 'pages.created_at > ?'
    @values << date.to_s(:db)
  end
  
  def filter_created_before(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @conditions << 'pages.created_at < ?'
    @values << date.to_s(:db)
  end
 
  # this is a grossly inefficient method
  def filter_month(month)
    offset = Time.zone.utc_offset
    @conditions << "MONTH(DATE_ADD(pages.`#{@date_field}`, INTERVAL '#{offset}' SECOND)) = ?"
    @values << month.to_i
  end

  def filter_year(year)
    offset = Time.zone.utc_offset
    @conditions << "YEAR(DATE_ADD(pages.`#{@date_field}`, INTERVAL '#{offset}' SECOND)) = ?"
    @values << year.to_i
  end
  
  #### FULLTEXT FILTERS
    
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

  # TODO: allow multiple OR tags instead of only AND tags
  # ie "+(this_tag or_this_tag)" rather than "+this_tag +and_this_tag"
  def filter_tag(tag_name)
    @tags << "+" + Page.searchable_tag_list([tag_name]).first
  end

  ### OTHER PAGE COLUMNS

  def filter_type(page_class_group)
    page_classes = Page.class_group_to_class_names(page_class_group)
    @conditions << 'pages.type IN (?)'
    @values << page_classes
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

  # in case sphinx is not available, but this should really never be used.
  def filter_text(text)
    @conditions << 'pages.title LIKE ?'
    @values << "%#{text}%"
  end
  
  #### sorting  ####
  
  def filter_ascending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "%s ASC" % sortkey
  end
  
  def filter_descending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "%s DESC" % sortkey
  end

  #### BOOLEAN ####  
  
  def filter_or
    @or_clauses << @conditions
    @conditions = []
  end
  
  ### LIMIT ###

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

end

