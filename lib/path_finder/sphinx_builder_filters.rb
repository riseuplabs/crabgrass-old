require 'path_finder/sphinx_builder'

class PathFinder::SphinxBuilder < PathFinder::Builder

  protected

  def filter_pending
    # TODO: make resolved pages be reflected immediately in the delta index (currently it is considered both resolved and not resolved until next index)
    @args_for_find[:conditions] << "@resolved 0"
  end

  
  def filter_type(page_class_group)
    @args_for_find[:conditions] << "@type "
    @args_for_find[:conditions] << Page.class_group_to_class_names(page_class_group).join("|")
  end
  
  def filter_person(id)
    @args_for_find[:conditions] << "@user_id #{id}"
  end
  
  def filter_group(id)
    @args_for_find[:conditions] << "@group_id #{id}"
  end

  def filter_created_by(id)
    @args_for_find[:conditions] << "@created_by_id #{id}"
  end

  def filter_not_created_by(id)
    @args_for_find[:conditions] << "@created_by_id -#{id}"
  end
  
  def filter_tag(tag_name)
    #TODO: implement tagging with has_many_polymorphisms
  end
  
  def filter_name(name)
    @args_for_find[:conditions] << "@name #{name}"
  end
  
  #### sorting  ####
  # when doing UNION, you can only ORDER BY
  # aliased columns. So, in case we are doing a
  # union, the sorting will use an alias
  
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
    RAILS_DEFAULT_LOGGER.debug @args_for_find.to_yaml
    @args_for_find[:conditions] = text + " " + @args_for_find[:conditions]
  end

end

