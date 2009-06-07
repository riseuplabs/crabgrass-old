# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    logged_in? and current_user.member_of?(@group)
#  end
module WikiPermission
  def may_edit_wiki?(group=@group)
    logged_in? and current_user.member_of?(group)
  end

  alias_method :may_old_version_messages?, :may_edit_wiki?
  alias_method :may_edit_area_messages?, :may_edit_wiki?
  alias_method :may_save_messages?, :may_edit_wiki?
  alias_method :may_done_messages?, :may_edit_wiki?
end
