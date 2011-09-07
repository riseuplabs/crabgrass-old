module Admin::SoundcloudPermission

  def may_show_soundcloud?
    may_admin_site?
  end

end
