# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    if @page
#      current_user.may? :admin, @page
#    else
#      true
#    end
#  end
module BasePage::SharePermission
  # only page admins may share the page.
  def may_update_share?(page=@page)
    !page or current_user.may? :admin, page
  end

  alias_method "may_notify_share?", :may_update_share?
  alias_method "may_show_popup_share?", :may_update_share?

end
