# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    logged_in? and current_user.member_of?(@group)
#  end
module WikiPermission
  def may_edit_wiki?(group=@group, wiki_id=nil)
    wiki = Wiki.find_by_id(wiki_id)
    if !wiki.nil? and wiki.profile
      may_edit_group_wiki?(wiki.profile.group)
    else    
      logged_in? and current_user.member_of?(group)
    end
  end

  def may_edit_group_wiki?(group=@group)
    logged_in? and (current_user.may?(:admin,group) or (current_user.member_of?(group) and group.profiles.public.members_may_edit_wiki?))
  end

  alias_method :may_old_version_wiki?, :may_edit_wiki?
  alias_method :may_edit_area_wiki?, :may_edit_wiki?
  alias_method :may_save_wiki?, :may_edit_wiki?
  alias_method :may_done_wiki?, :may_edit_wiki?
end

