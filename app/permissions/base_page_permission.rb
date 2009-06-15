#
# All page controllers will fall back to using these permissions if no
# other permission is found.
#
module BasePagePermission

  # if no other appropriate methods are defined, fallback to this one:
  def default_permission
    current_user.may?(:admin, @page)
  end

  def may_edit_base_page?(page = @page)
    current_user.may?(:edit, page)
  end

  def may_create_base_page?(page = @page)
    !page or current_user.may?(:admin, page)
  end

  alias_method :may_delete_base_page?, :may_create_base_page?
  alias_method :may_undelete_base_page?, :may_create_base_page?

  # Trash
  alias_method :may_show_popup_trash?, :may_delete_base_page?

  def may_show_base_page?(page = @page)
    !page or current_user.may?(:view, page)
  end

  # this is some really horrible stuff that i want to go away very quickly.
  # some sites want to restrict page deletion to only people who are admins
  # of groups that have admin access to the page. crabgrass does not work this
  # way and is a total violation of the permission logic. there is a better way,
  # and it should be replaced for this.
  def may_destroy_base_page?(page = @page)
    return true if page.nil?
    parts = []
    parts << page.participation_for_user(current_user)
    parts.concat page.participation_for_groups(current_user.admin_for_group_ids)
    return parts.compact.detect{|part| part.access == ACCESS[:admin]}
  end

  # we are using may_remove_page from trash controllers.
  alias_method :may_remove_base_page?, :may_destroy_base_page?

  # this can only be used from authorized? because of
  # checking the params. Use one of
  #  - may_delete_base_page?
  #  - may_destroy_base_page?
  # from the views and helpers.
  def may_update_trash?(page=@page)
    if params[:cancel]
      may_delete_base_page?
    elsif params[:delete] && params[:type]=='move_to_trash'
      may_delete_base_page?
    elsif params[:delete] && params[:type]=='shred_now'
      may_destroy_base_page?
    else
      false
    end
  end
end
