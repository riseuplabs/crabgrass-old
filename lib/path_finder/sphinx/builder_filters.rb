# = PathFinder::Sql::BuilderFilters
# This contains all the filters for the different path elements.
# It gets included from the Builder.
#  

module PathFinder::Sphinx::BuilderFilters

  protected

  def filter_unread
    raise Exception.new("sphinx cannot search for unread")
  end

  def filter_pending
    @conditions[:resolved] = 0
  end
  
  def filter_interesting
    raise Exception.new("sphinx cannot search for interesting")
  end

  def filter_watching
    raise Exception.new("sphinx cannot search for watching")
  end

  def filter_inbox
    raise Exception.new("sphinx cannot search for inbox")
  end

  def filter_attending
    raise Exception.new("sphinx cannot search for attending")
  end

  def filter_starred
    raise Exception.new("sphinx cannot search for starred")
  end

  def filter_changed
    raise Exception.new("sphinx cannot search for changed")
  end
    
  #--
  ### Time finders
  # dates in database are UTC
  # we assume the values pass to the finder are local
  #++

  def filter_starts
    @date_field = :starts_at
  end

  def filter_after(date)
    if date == 'now'
       date = Time.zone.now
    else
       if date == 'today'
          date = to_utc(local_now.at_beginning_of_day)
       else
          year, month, day = date.split('-')
          date = to_utc Time.in_time_zone(year, month, day)
       end
    end
    @conditions[@date_field] = range(date, date+100.years)
  end

  def filter_before(date)
    if date == 'now'
       date = Time.now
    else
       if date == 'today'
          date = Time.zone.now.to_date
       else
          year, month, day = date.split('-')
          date = to_utc Time.in_time_zone(year, month, day)
       end
    end
    @conditions[@date_field] = range(date-100.years, date)
  end

  def filter_upcoming
    @conditions[:starts_at] = range(Time.zone.now, Time.zone.now + 100.years)
    @order << 'pages.starts_at DESC'
  end
  
  def filter_ago(near,far)
    @conditions[:page_updated_at] = range(far.to_i.days.ago, near.to_i.days.ago)
  end
  
  def filter_created_after(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @conditions[:page_created_at] = range(date, date + 100.years)
  end
  
  def filter_created_before(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @conditions[:page_created_at] = range(date - 100.years, date)
  end
 
  def filter_month(month)
    year = Time.zone.now.year
    @conditions[@date_field] = range(Time.in_time_zone(year,month), Time.in_time_zone(year,month+1))
  end

  def filter_year(year)
    @conditions[:date_field] = range(Time.in_time_zone(year), Time.in_time_zone(year+1))
  end
  
  ####

  def filter_type(page_class_group)
    @conditions[:page_type] = Page.class_group_to_class_names(page_class_group).join(' ')
  end
  
  def filter_person(id)
    @with[access_ids_key] = Page.access_ids_for(:user_ids => [id])
  end
  
  def filter_group(id)
    @with[access_ids_key] = Page.access_ids_for(:group_ids => [id])
  end

  def filter_created_by(id)
    @conditions[:created_by_id] ||= ""
    @conditions[:created_by_id] += " #{id}"
  end

  def filter_not_created_by(id)
    @without[:created_by_id] ||= ""
    @without[:created_by_id] += " #{id}"
  end
  
  def filter_tag(tag_name)
    @conditions[:tags] ||= ""
    @conditions[:tags] += " #{tag_name}"
  end
  
  def filter_name(name)
    @conditions[:name] ||= ""
    @conditions[:name] += " #{name}"
  end

  def filter_stars(star_count)
    @conditions[:stars] = range(star_count, 10000)
  end

  def filter_starred
    filter_stars(1)
  end
  
  #--
  #### sorting  ####
  #++
  
  def filter_ascending(sortkey)
    if sortkey == 'updated_at' or sortkey == 'created_at'
      sortkey = 'page_' + sortkey
    end
    @order << " #{sortkey} ASC"
  end
  
  def filter_descending(sortkey)
    if sortkey == 'updated_at' or sortkey == 'created_at'
      sortkey = 'page_' + sortkey
    end
    @order << " #{sortkey} DESC"
  end
  
  #--
  ### LIMIT ###
  #++
  
  def filter_limit(limit)
    offset = 0
    if limit.instance_of? String 
      limit, offset = limit.split('-')
    end
    @per_page = limit.to_i if limit
    @page = ((offset.to_f/limit.to_f) + 1).floor.to_i if @per_page > 0
  end
  
  def filter_text(text)
    @search_text += " #{text}"
  end

  #--
  ### HELPER ###
  #++

  def range(min,max)
    min.to_i..max.to_i
  end
end

