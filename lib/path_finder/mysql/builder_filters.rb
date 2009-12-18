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

  # def filter_starts
  #   @date_field = "starts_at"
  # end
  #
  # def filter_created
  #   @date_field = "created_at"
  # end

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

  # def filter_upcoming
  #   @conditions << 'pages.starts_at > ?'
  #   @values << Time.now
  #   @order << 'pages.starts_at DESC' if @order
  # end

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

  # filter on page type or types, and maybe even media flag too!
  # eg values:
  # media-image+file, media-image+gallery, file,
  # text+wiki, text, wiki
  def filter_type(arg)
    return if arg == 'all'

    if arg =~ /[\+\ ]/
      page_group, page_type = arg.split(/[\+\ ]/)
    elsif Page.is_page_group?(arg)
      page_group = arg
    elsif Page.is_page_type?(arg)
      page_type = arg
    end

    if page_group =~ /^media-(image|audio|video|document)$/
      media_type = page_group.sub(/^media-/,'')
      @conditions << "pages.is_#{media_type} = ?" # only safe because of regexp in if
      @values << true
    end

    if page_type == 'announcement'
      @flow = :announcement
    end

    if page_type
      @conditions << 'pages.type = ?'
      @values << Page.param_id_to_class_name(page_type) # eg 'RateManyPage'
    elsif page_group
      @conditions << 'pages.type IN (?)'
      @values << Page.class_group_to_class_names(page_group) # eg ['WikiPage','SurveyPage']
    else
      # we didn't find either a type or a group for arg
      # just search for arg. this should return an empty set
      @conditions << 'pages.type = ?'
      @values <<  arg # example 'bad_page_type'
    end
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
    @conditions << 'pages.stars_count >= ?'
    @values << star_count
  end

  def filter_starred
    @conditions << 'pages.stars_count > 0'
  end

  def filter_contributed
    @conditions << 'pages.contributors_count > 0'
  end

  #--
  #### sorting  ####
  #++

  def filter_ascending(sortkey)
    sortkey = 'views_count' if sortkey == 'views'
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "%s.%s ASC" % [@klass.table_name, sortkey]
  end

  def filter_descending(sortkey)
    sortkey = 'views_count' if sortkey == 'views'
    sortkey.gsub!(/[^[:alnum:]]+/, '_')
    @order << "%s.%s DESC" % [@klass.table_name, sortkey]
  end

  def filter_most(what, num, unit)
    unit=unit.downcase.pluralize
    name= what=="edits" ? "contributors" : what
    num.gsub!(/[^\d]+/, ' ')
    if unit=="days"
      @conditions << "dailies.created_at > UTC_TIMESTAMP() - INTERVAL %s DAY" % num
      @order << "SUM(dailies.#{what}) DESC"
      @select = "pages.*, SUM(dailies.#{what}) AS #{name}_count"
    elsif unit=="hours"
      @conditions << "hourlies.created_at > UTC_TIMESTAMP() - INTERVAL %s HOUR" % num
      @order << "SUM(hourlies.#{what}) DESC"
      @select = "pages.*, SUM(hourlies.#{what}) AS #{name}_count"
    else
      return
    end
  end

  def filter_most_views(num, unit)
    filter_most("views", num, unit)
  end

  def filter_most_edits(num, unit)
    filter_most("edits", num, unit)
  end

  def filter_most_stars(num, unit)
    filter_most("stars", num, unit)
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
    @order << "group_participations.featured_position ASC"
  end

  def filter_contributed_by(user_id)
    @conditions << 'user_participations.user_id = ? AND user_participations.changed_at IS NOT NULL'
    @values << [user_id.to_i]
    @order << "user_participations.changed_at DESC" if @order
  end

  def filter_admin(user_id)
    @conditions << 'user_participations.user_id = ? AND user_participations.access = ?'
    @values << user_id.to_i
    @values << ACCESS[:admin]
  end

  def filter_contributed_group(group_id)
    @conditions << 'user_participations.user_id IN (?) AND user_participations.changed_at IS NOT NULL'
    @values << Group.find(group_id).user_ids
    @order = ["user_participations.changed_at DESC"]
  end

  #--
  ## MODERATION
  #++

  def filter_public()
    @conditions << "pages.public = TRUE"
  end

  def filter_public_requested()
    @conditions << "pages.public_requested = TRUE"
  end

  def filter_moderation(state)
    @conditions << ModeratedFlag.conditions_for_view(state)
  end

#turning RDoc comments back on.
#++
end


