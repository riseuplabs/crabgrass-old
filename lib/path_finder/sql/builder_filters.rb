# = PathFinder::Sql::BuilderFilters
# This contains all the filters for the different path elements.
# It gets included from the Builder.
#  

module PathFinder::Sql::BuilderFilters

  protected
  
  def filter_unread
    @conditions << 'user_participations.viewed = ?'
    @values << false  
  end
  
  def filter_pending
    if @inbox
      @conditions << 'user_participations.resolved = ?'
    else
      @conditions << 'pages.resolved = ?'
    end
    @values << false
  end

  def filter_interesting
    @conditions << '(user_participations.watch = ? or user_participations.attend = ?)'
    @values << true
    @values << true
  end

  def filter_watching
    @conditions << 'user_participations.watch = ?'
    @values << true
  end

  def filter_inbox
    @conditions << 'user_participations.inbox = ?'
    @values << true
  end

  def filter_attending
    @conditions << 'user_participations.attend = ?'
    @values << true
  end

  def filter_starred
    @conditions << 'user_participations.star = ?'
    @values << true
  end
  
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

  #--
  ### Time finders
  # dates in database are UTC
  # we assume the values pass to the finder are local
  #++
  
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
 
  #--
  # this is a grossly inefficient method
  #++
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
  
  ####
  
  def filter_type(page_class_group)
    page_classes = Page.class_group_to_class_names(page_class_group)
    @conditions << 'pages.type IN (?)'
    @values << page_classes
  end
  
  def filter_person(id)
    @conditions << 'user_parts.user_id = ?'
    @values << id
  end
  
  def filter_group(id)
    @conditions << 'group_parts.group_id = ?'
    @values << id
  end

  def filter_created_by(id)
    @conditions << 'pages.created_by_id = ?'
    @values << id 
  end

  def filter_not_created_by(id)
    @conditions << 'pages.created_by_id != ?'
    @values << id 
  end
  
  def filter_tag(tag_name)
    if tag = Tag.find_by_name(tag_name)
      # TODO:  accept more than 4 tags, or issue a vaild error message
      return unless @tag_count < 4
      @tag_count += 1
      @conditions << "taggings#{@tag_count}.tag_id = ?"
      @values << tag.id
    else
      @conditions << "FALSE"
    end
  end
  
  def filter_name(name)
    @conditions << 'pages.name = ?'
    @values << name
  end
  
  #--
  #### sorting  ####
  # when doing UNION, you can only ORDER BY
  # aliased columns. So, in case we are doing a
  # union, the sorting will use an alias
  #++
  
  def filter_ascending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    if @aliases and @order
      # ^^^ these might be nil, like when doing a count where order doesn't matter.
      @aliases << ["pages.`%s` AS pages_%s" % [sortkey,sortkey]]
      @order << "pages_%s ASC" % sortkey
    end
  end
  
  def filter_descending(sortkey)
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    if @aliases and @order
      # ^^^ these might be nil, like when doing a count where order doesn't matter.
      @aliases << ["pages.`%s` AS pages_%s" % [sortkey,sortkey]]
      @order << "pages_%s DESC" % sortkey
    end
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

  def filter_text(text)
    @conditions << 'pages.title LIKE ?'
    @values << "%#{text}%"
  end

end

