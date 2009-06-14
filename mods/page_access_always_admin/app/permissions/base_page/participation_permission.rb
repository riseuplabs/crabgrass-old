module BasePage::ParticipationPermission
  # all permissions are set to admin automatically.
  def may_select_participation(page=@page)
    false
  end
end
