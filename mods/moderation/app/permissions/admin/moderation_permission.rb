module Admin::ModerationPermission
  def may_moderate?
    current_user.moderator?(current_site)
  end
end
