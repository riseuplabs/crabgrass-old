module WidgetsPermission

  def may_show_widget?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_update_widget?, :may_show_widget?
  def may_edit_widget?
    current_user.may?(:admin, current_site)
  end

end