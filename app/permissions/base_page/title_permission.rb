module BasePage::TitlePermission
#  def authorized?
#    current_user.may?(:edit, @page)
#  end
  def may_update_title?(page=@page)
    page and current_user.may? :edit, page
  end

  %w(edit).each{ |action|
    alias_method "may_#{action}_title?".to_sym, :may_update_title?
  }
end
