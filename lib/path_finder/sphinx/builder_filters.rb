# = PathFinder::Sphinx::BuilderFilters
#
# This contains all the filters for the different path elements.
# It gets included from the Builder.
#
#
# These fields are defines as sphinx attributes, and should use
# @with instead of @conditions:
#
# :sphinx_internal_id, :class_crc, :sphinx_deleted, :title_sort,
# :page_type_sort, :created_by_login_sort, :updated_by_login_sort,
# :owner_name_sort, :page_created_at, :page_updated_at, :views_count,
# :created_by_id, :updated_by_id, :resolved, :stars_count, :access_ids,
# :media
#
# NOTE: @conditions is a hash, @with is an array.
#
# in sphinx, attributes are numeric only. 
#

module PathFinder::Sphinx::BuilderFilters

  protected

  def filter_unread
    raise Exception.new("sphinx cannot search for unread")
  end

  def filter_pending
    @with << [:resolved, 0]
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

  # def filter_starts
  #   @date_field = :created_at
  # end
  #
  # def filter_after(date)
  #   if date == 'now'
  #      date = Time.zone.now
  #   else
  #      if date == 'today'
  #         date = to_utc(local_now.at_beginning_of_day)
  #      else
  #         year, month, day = date.split('-')
  #         date = to_utc Time.in_time_zone(year, month, day)
  #      end
  #   end
  #   @conditions[@date_field] = range(date, date+100.years)
  # end
  #
  # def filter_before(date)
  #   if date == 'now'
  #      date = Time.now
  #   else
  #      if date == 'today'
  #         date = Time.zone.now.to_date
  #      else
  #         year, month, day = date.split('-')
  #         date = to_utc Time.in_time_zone(year, month, day)
  #      end
  #   end
  #   @conditions[@date_field] = range(date-100.years, date)
  # end
  #
  # def filter_upcoming
  #   @conditions[:starts_at] = range(Time.zone.now, Time.zone.now + 100.years)
  #   @order << 'pages.starts_at DESC'
  # end

  def filter_ago(near,far)
    @with << [:page_updated_at, range(far.to_i.days.ago, near.to_i.days.ago)]
  end

  def filter_created_after(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @with << [:page_created_at, range(date, date + 100.years)]
  end

  def filter_created_before(date)
    year, month, day = date.split('-')
    date = to_utc Time.in_time_zone(year, month, day)
    @with << [:page_created_at, range(date - 100.years, date)]
  end

  # def filter_month(month)
  #   year = Time.zone.now.year
  #   @conditions[@date_field] = range(Time.in_time_zone(year,month), Time.in_time_zone(year,month+1))
  # end
  #
  # def filter_year(year)
  #   @conditions[:date_field] = range(Time.in_time_zone(year), Time.in_time_zone(year+1))
  # end

  ####

  # filter on page type or types, and maybe even media flag too!
  # eg values:
  # media-image+file, media-image+gallery, file,
  # text+wiki, text, wiki
  def filter_type(arg)
    if arg =~ /[\+\ ]/
      page_group, page_type = arg.split(/[\+\ ]/)
    elsif Page.is_page_group?(arg)
      page_group = arg
    elsif Page.is_page_type?(arg)
      page_type = arg
    end

    if page_group =~ /^media-(image|audio|video|document)$/
      media_type = page_group.sub(/^media-/,'').to_sym
      @with << [:media, MEDIA_TYPE[media_type]] # indexed as multi array of ints.
    end

    if page_type
      @conditions[:page_type] = Page.param_id_to_class_name(page_type)
    elsif page_group
      @conditions[:page_type] = Page.class_group_to_class_names(page_group).join('|')
    else
      # we didn't find either a type or a group for arg
      # just search for arg. this should return an empty set
      @conditions[:page_type] = arg.dup
    end
  end

  def filter_person(id)
    @with << [:access_ids, Page.access_ids_for(:user_ids => [id])]
  end

  def filter_group(id)
    @with << [:access_ids, Page.access_ids_for(:group_ids => [id])]
  end

  def filter_created_by(id)
    @with << [:created_by_id, id]
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
    @with << [:stars_count, range(star_count, 10000)]
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

