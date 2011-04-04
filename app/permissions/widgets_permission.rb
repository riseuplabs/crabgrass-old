module WidgetsPermission

  def may_show_widget?
    current_user.may?(:admin, current_site)
  end

  alias_method :may_new_widget?, :may_show_widget?
  alias_method :may_sidebar_widget?, :may_new_widget?
  alias_method :may_create_widget?, :may_show_widget?
  alias_method :may_update_widget?, :may_show_widget?
  alias_method :may_sort_widget?, :may_show_widget?
  alias_method :may_destroy_widget?, :may_show_widget?
  def may_edit_widget?
    current_user.may?(:admin, current_site)
  end

end
