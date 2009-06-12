# These permissions are a replacement for the following authorized? method:
#  def authorized?
#    if action?('update_public','create','destroy', 'move','set_owner')
#      current_user.may? :admin, @page
#    else
#      current_user.may? :view, @page
#    end
#  end
module BasePage::ParticipationPermission
  def may_create_participation?(page=@page)
    page and current_user.may? :admin, page
  end

  alias_method :may_update_public_participation?, :may_create_participation?
  alias_method :may_destroy_participation?, :may_create_participation?
  alias_method :may_move_participation?, :may_create_participation?
  alias_method :may_set_owner_participation?, :may_create_participation?

  def may_read_participation?(page=@page)
    page and current_user.may? :view, page
  end

  alias_method :may_add_star_participation?, :may_read_participation?
  alias_method :may_remove_star_participation?, :may_read_participation?
  alias_method :may_add_watch_participation?, :may_read_participation?
  alias_method :may_remove_watch_participation?, :may_read_participation?
  alias_method :may_show_popup_participation?, :may_read_participation?
  alias_method :may_close_details_participation?, :may_read_participation?
end
