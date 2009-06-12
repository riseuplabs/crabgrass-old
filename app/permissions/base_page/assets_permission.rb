# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    current_user.may? :edit, @page
#  end
module BasePage::AssetsPermission
  def may_create_assets?(page=@page)
    page and current_user.may? :edit, page
  end

  alias_method :may_destroy_assets?, :may_create_assets?
  alias_method :may_close_assets?, :may_create_assets?
  alias_method :may_show_popup_assets?, :may_create_assets?
  alias_method :may_update_cover_assets?, :may_create_assets?
end
