module WikiPageVersionPermission

  #  WikiPageVersion
  #  def authorized?
  #   if action?(:show, :diff, :list)
  #     @page.public? or current_user.may?(:view, @page)
  #   elsif action?(:revert)
  #     current_user.may?(:edit, @page)
  #   else
  #     current_user.may?(:admin, @page)
  #   end
  #  end
  #
  def may_show_wiki_page_version?(page=@page)
    page.public? or
    logged_in? && current_user.may?(:view, page)
  end

  %w[diff list].each{ |action|
    alias_method "may_#{action}_wiki_page_version?", :may_show_wiki_page_version?
  }

  def may_revert_wiki_page_version?(page=@page)
    logged_in? && current_user.may?(:edit, page)
  end
end
