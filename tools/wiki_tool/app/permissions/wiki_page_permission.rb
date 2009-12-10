module WikiPagePermission
  def may_show_wiki_page?(page = @page)
    page.nil? or
    page.public? or
    logged_in? && current_user.may?(:view, page)
  end

  alias_method :may_print_wiki_page?, :may_show_wiki_page?

  def may_edit_wiki_page?(page = @page)
    page.nil? or
    logged_in? && current_user.may?(:edit, page)
  end

  %w[update upload update_editors].each{ |action|
    alias_method "may_#{action}_wiki_page?", :may_edit_wiki_page?
  }

end
