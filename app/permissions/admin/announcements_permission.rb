module Admin::AnnouncementsPermission
  def may_index_announcements?
    current_site.id and may_admin_site?
  end

  alias_method :may_create_announcements?, :may_index_announcements?
  alias_method :may_edit_announcements?, :may_index_announcements?
  alias_method :may_destroy_announcements?, :may_index_announcements?
end
