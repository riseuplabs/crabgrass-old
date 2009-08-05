module Admin::ModerationPermission
  def may_moderate?
    current_user.moderator?
  end
end
