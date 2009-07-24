module ControllerExtension::ContextParser

  # returns the group and the page for a particular context path
  # eg.
  #   entity, page = resolve_context('riseup', 'minutes')
  #
  # This would correspond to: https://we.riseup.net/riseup/minutes
  #
  def resolve_context(context_name, page_name, allow_multiple_results=false)

    #
    # Context
    #

    if context_name =~ /\ /
      # we are dealing with a committee!
      context_name.sub!(' ','+')
    end

    group = Group.find_by_name(context_name)
    user  = User.find_by_login(context_name) unless group

    #
    # Page
    #

    if page_name.nil?
      unless group || user
        raise ActiveRecord::RecordNotFound.new
      end
    elsif page_name =~ /[ +](\d+)$/ || page_name =~ /^(\d+)$/
      # if page handle ends with [:space:][:number:] or entirely just numbers
      # then find by page id. (the url actually looks like "my-page+52", but
      # pluses are interpreted as spaces). find by id will always return a
      #  globally unique page so we can ignore context
      page = find_page_by_id( $~[1] )
    elsif group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      page = find_page_by_group_and_name(group, page_name)
    elsif user and !allow_multiple_results
      page = find_page_by_user_and_name(user, page_name)
    elsif user and allow_multiple_results
      page = find_pages_by_user_and_name(user, page_name)
    end

    raise ActiveRecord::RecordNotFound.new unless page

    return [(group||user), page]
  end

  private

  def includes
    nil
  end

  def find_page_by_id(id)
    Page.find_by_id(id.to_i, :include => includes )
  end

  # almost every page is fetched using this function.
  # Page names should be unique across all the groups in the namespace.
  def find_page_by_group_and_name(group, name)
    ids = Group.namespace_ids(group.id)
    Page.find(:first, :conditions => ['pages.name = ? AND group_participations.group_id IN (?)', name, ids], :joins => :group_participations)
  end

  def find_page_by_user_and_name(user, name)
    user.pages.find(:first, :conditions => ['pages.name = ?',name])
  end

  def find_pages_by_user_and_name(user, name)
    user.pages.find(:all, :conditions => ['pages.name = ?',name])
  end

end

