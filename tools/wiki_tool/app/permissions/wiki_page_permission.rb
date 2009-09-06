module WikiPagePermission
  # WikiPage
  #  def authorized?
  #    if @page
  #      if %w(show print).include? params[:action]
  #        @page.public? or current_user.may?(:view, @page)
  #      elsif %w(edit break_lock upload).include? params[:action]
  #        current_user.may?(:edit, @page)
  #      else
  #        current_user.may?(:admin, @page)
  #      end
  #    else
  #      true
  #    end
  #  end
  def may_print_wiki_page?(page = @page)
    page.nil? or
    page.public? or
    logged_in? && current_user.may?(:view, page)
  end

  def may_edit_wiki_page?(page = @page)
    page.nil? or
    logged_in? && current_user.may?(:edit, page)
  end

  %w[break_lock upload update_editors].each{ |action|
    alias_method "may_#{action}_wiki_page?", :may_edit_wiki_page?
  }

end
