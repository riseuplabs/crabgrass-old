module BasePage::ParticipationPermission
  # permissions are fixed to :admin on this install.
  def may_select_access_participation?(page=@page)
    false
  end
end
