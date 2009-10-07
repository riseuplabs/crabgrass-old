module BasePagePermission
  # permissions are fixed to :admin on this install.
  def may_select_access_participation?(page=@page)
    may_admin_site?
  end

  def may_notify_page?(page=@page)
    may_admin_site?
  end
end
