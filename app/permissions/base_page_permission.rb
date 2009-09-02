#
# All page controllers will fall back to using these permissions if no
# other permission is found.
#
module BasePagePermission

  # if no other appropriate methods are defined, fallback to this one:
  def default_permission
    may_admin_page?
  end

  def may_admin_page?(page = @page)
    current_user.may?(:admin, @page)
  end

  def may_edit_page?(page = @page)
    current_user.may?(:edit, page)
  end

  def may_create_page?(page = @page)
    !page or may_admin_page?
  end

  # public pages are dealt with in login_or_public_page_required
  # in the controller.
  def may_show_page?(page = @page)
    !page or current_user.may?(:view, page)
  end

  ##
  ## TRASH
  ##

  alias_method :may_delete_page?, :may_create_page?
  alias_method :may_undelete_page?, :may_create_page?

  alias_method :may_show_trash?, :may_delete_page?

  # this is some really horrible stuff that i want to go away very quickly.
  # some sites want to restrict page deletion to only people who are admins
  # of groups that have admin access to the page. crabgrass does not work this
  # way and is a total violation of the permission logic. there is a better way,
  # and it should be replaced for this.
  def may_destroy_page?(page = @page)
    return true if page.nil?
    parts = []
    parts << page.participation_for_user(current_user)
    parts.concat page.participation_for_groups(current_user.admin_for_group_ids)
    return parts.compact.detect{|part| part.access == ACCESS[:admin]}
  end

  # we are using may_remove_page from trash controllers.
  alias_method :may_remove_page?, :may_destroy_page?

  # this can only be used from authorized? because of
  # checking the params. Use one of
  #  - may_delete_page?
  #  - may_destroy_page?
  # from the views and helpers.
  def may_update_trash?(page=@page)
    if params[:cancel]
      may_delete_page?
    elsif params[:delete] && params[:type]=='move_to_trash'
      may_delete_page?
    elsif params[:delete] && params[:type]=='shred_now'
      may_destroy_page?
    else
      false
    end
  end

  ##
  ## TAGS
  ##

  alias_method :may_update_tags?, :may_edit_page?
  alias_method :may_show_tags?, :may_update_tags?

  ##
  ## ASSETS
  ##

  alias_method :may_create_assets?, :may_edit_page?
  alias_method :may_destroy_assets?, :may_create_assets?
  alias_method :may_show_assets?, :may_create_assets?
  alias_method :may_update_assets?, :may_create_assets?

  ##
  ## SHARING
  ##

  alias_method :may_share_page?, :may_admin_page?
  alias_method :may_notify_page?, :may_edit_page?

  def may_share_with_all?
    !Site.current.try.network.nil? and may_share_page?
  end

  ##
  ## PARTICIPATION
  ##

  alias_method :may_star_page?, :may_show_page?
  alias_method :may_watch_page?, :may_show_page?
  alias_method :may_public_page?, :may_admin_page?
  alias_method :may_move_page?, :may_admin_page?
  alias_method :may_share_page?, :may_admin_page?

  alias_method :may_create_participation?, :may_admin_page?
  alias_method :may_destroy_participation?, :may_create_participation?
  alias_method :may_show_participation?,    :may_show_page?
  alias_method :may_index_participation?,    :may_show_page?

  # This is needed for the views to destinct between displaying access
  # levels or not displaying them on cc.net
  def may_select_access_participation?(page=@page)
    page.nil? or current_user.may? :admin, page
  end

  def may_remove_participation?(part)
    if part.is_a?(UserParticipation)
      part.user_id and
      part.user != @page.owner and
      current_user.may_admin_page_without?(@page, part)
      # may_create_participation? || current_user == page.user
    elsif part.is_a?(GroupParticipation)
      part.group_id and
      part.group != @page.owner and
      current_user.may_admin_page_without?(@page, part)
      # may_create_participation? || current_user.admin_for_group_ids.include?(gpart.group_id)
    else false
    end
  end
  ##
  ## TITLE
  ##

  alias_method :may_update_title?, :may_edit_page?
  alias_method :may_edit_title?, :may_update_title?

end
