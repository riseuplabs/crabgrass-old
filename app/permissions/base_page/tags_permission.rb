module BasePage::TagsPermission 
#  def authorized?
#    current_user.may?(:edit, @page)
#  end
  def may_update_tags?(page=@page)
    page and current_user.may? :edit, page
  end

  %w(show_popup).each{ |action|
    alias_method "may_#{action}_tags?".to_sym, :may_update_tags?
  }
end
