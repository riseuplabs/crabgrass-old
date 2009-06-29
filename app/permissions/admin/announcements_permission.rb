module Admin::AnnouncementsPermission
  def may_index_announcements?
    current_user.may?(:admin, current_site)
  end
end
