require 'path_finder/sphinx_builder'

module PathFinder::SphinxBuilderFilters

  protected

  def filter_unread
    Raise "sphinx cannot search for unread"
  end

  def filter_pending
    Raise "sphinx cannot search inbox for pending" if @inbox
    @args_for_find[:conditions] << " @resolved 0"
  end
  
  def filter_interesting
    Raise "sphinx cannot search for interesting"
  end

  def filter_watching
    Raise "sphinx cannot search for watching"
  end

  def filter_inbox
    Raise "sphinx cannot search for inbox"
  end

  def filter_attending
    Raise "sphinx cannot search for attending"
  end

  def filter_starred
    Raise "sphinx cannot search for starred"
  end

  def filter_starts
    # TODO: check if this has intended effect
    @date_field = "starts_at"
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
    @args_for_find[:filter] = @date_field
    @args_for_find[:filter_start] = date    
    @args_for_find[:filter_stop] = date + 100.years
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
    @args_for_find[:filter] = @date_field
    @args_for_find[:filter_start] = date - 100.years
    @args_for_find[:filter_stop] = date
  end

  def filter_changed
    Raise "sphix cannot search for changed"
  end
      
  ### Time finders
  # dates in database are UTC
  # we assume the values pass to the finder are local
  
  def filter_upcoming
    @args_for_find[:filter] = "starts_at"
    @args_for_find[:filter_start] = Time.zone.now
    @args_for_find[:filter_stop] = Time.zone.now + 100.years
    @order << 'pages.starts_at DESC' if @order
  end
  
  def filter_ago(near,far)
    @args_for_find[:filter] = "updated_at"
    @args_for_find[:filter_start]  = far.to_i.days.ago
    @args_for_find[:filter_stop] = near.to_i.days.ago
  end
  
  def filter_created_after(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @args_for_find[:filter] = "created_at"
    @args_for_find[:filter_start]  = date
    @args_for_find[:filter_stop] = date + 100.years
  end
  
  def filter_created_before(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @args_for_find[:filter] = "created_at"
    @args_for_find[:filter_start]  = date - 100.years
    @args_for_find[:filter_stop] = date
  end
 
  def filter_month(month)
    year = Time.zone.now.year
    @args_for_find[:filter] = @date_field
    @args_for_find[:filter_start]  = Time.in_time_zone(year,month)
    @args_for_find[:filter_stop] = Time.in_time_zone(year,month+1)
  end

  def filter_year(year)
    @args_for_find[:filter] = @date_field
    @args_for_find[:filter_start]  = Time.in_time_zone(year)
    @args_for_find[:filter_stop] = Time.in_time_zone(year + 1)
  end
  
  ####

  def filter_type(page_class_group)
    @args_for_find[:conditions] << " @class_display_name #{page_class_group}"
  end
  
  def filter_person(id)
    @args_for_find[:conditions] << " @user_id #{id}"
  end
  
  def filter_group(id)
    @args_for_find[:conditions] << " @group_id #{id}"
  end

  def filter_created_by(id)
    @args_for_find[:conditions] << " @created_by_id #{id}"
  end

  def filter_not_created_by(id)
    @args_for_find[:conditions] << " @created_by_id -#{id}"
  end
  
  def filter_tag(tag_name)
    @args_for_find[:conditions] << " @tags #{tag_name}"
  end
  
  def filter_name(name)
    @args_for_find[:conditions] << " @name #{name}"
  end
  
  #### sorting  ####
  
  def filter_ascending(sortkey)
    @args_for_find[:order] = "#{sortkey} ASC"
  end
  
  def filter_descending(sortkey)
    @args_for_find[:order] = "#{sortkey} DESC"
  end
  
  ### LIMIT ###
  
  def filter_limit(limit)
    offset = nil
    if limit.instance_of? Array 
      limit, offset = limit.split('-')
    end

    @args_for_find[:per_page] = limit.to_i if limit
    @args_for_find[:page] = offset.to_i / limit.to_i if offset and limit
  end
  
  def filter_text(text)
#    RAILS_DEFAULT_LOGGER.debug @args_for_find.to_yaml
    @args_for_find[:conditions] = text + " " + @args_for_find[:conditions]
  end

end

