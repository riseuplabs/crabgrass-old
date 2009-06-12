# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    current_user.may?(:edit, @page)
#  end
module BasePage::TagsPermission
  def may_update_tags?(page=@page)
    page and current_user.may? :edit, page
  end
  alias_method :may_show_popup_tags?, :may_update_tags?
end
