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

  %w[break_lock upload].each{ |action|
    alias_method "may_#{action}_wiki_page?", :may_edit_wiki_page?
  }

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
