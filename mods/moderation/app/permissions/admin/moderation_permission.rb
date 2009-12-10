module Admin::ModerationPermission
  def may_see_moderation_panel?
    current_user.moderates?
  end

  def may_moderate?
    current_user.moderator? or
    @page and current_user.may_moderate?(@page)
  end
end
