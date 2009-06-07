# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    current_user.may?(:edit, @page)
#  end
module BasePage::TitlePermission
  def may_update_title?(page=@page)
    page and current_user.may? :edit, page
  end

  alias_method :may_edit_title?, :may_update_title?
end
