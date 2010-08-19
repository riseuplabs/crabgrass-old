# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    logged_in? and current_user.member_of?(@group)
#  end
module WikiPermission
  def may_edit_wiki?(group=@group, wiki_id=nil)
    logged_in? and current_user.member_of?(group)
    may_edit_group_wiki?(group=@group) if (!wiki_id.nil? and group.profiles.public.wiki_id == wiki_id)
  end

  alias_method :may_old_version_wiki?, :may_edit_wiki?
  alias_method :may_edit_area_wiki?, :may_edit_wiki?
  alias_method :may_save_wiki?, :may_edit_wiki?
  alias_method :may_done_wiki?, :may_edit_wiki?
end

