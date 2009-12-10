# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    return true
#  end
module MePermission
  # always have access to self
  def may_edit_me?
    logged_in?
  end

  alias_method :may_index_me?, :may_edit_me?
  alias_method :may_counts_me?, :may_edit_me?
  alias_method :may_delete_avatar_me?, :may_edit_me?

  # Dashboard
  alias_method :may_index_dashboard?, :may_edit_me?
  alias_method :may_show_welcome_box_dashboard?, :may_edit_me?
  alias_method :may_close_welcome_box_dashboard?, :may_edit_me?

  # Inbox
  alias_method :may_search_inbox?, :may_edit_me?
  alias_method :may_index_inbox?, :may_edit_me?
  alias_method :may_list_inbox?, :may_edit_me?
  alias_method :may_update_inbox?, :may_edit_me?
  alias_method :may_remove_inbox?, :may_edit_me?

  # Infoviz
  alias_method :may_visualize_infoviz?, :may_edit_me?

  # Requests
  alias_method :may_from_me_requests?, :may_edit_me?
  alias_method :may_to_me_requests?, :may_edit_me?

  # Search
  alias_method :may_index_search?, :may_edit_me?

  # Tasks
  alias_method :may_pending_tasks?, :may_edit_me?
  alias_method :may_completed_tasks?, :may_edit_me?

  # Trash
  alias_method :may_search_trash?, :may_edit_me?
  alias_method :may_index_trash?, :may_edit_me?
  alias_method :may_list_trash?, :may_edit_me?
  alias_method :may_update_trash?, :may_edit_me?

end
