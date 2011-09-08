module Admin::SoundcloudPermission

  def may_show_soundcloud?
    may_admin_site?
  end

  alias_method :may_new_soundcloud?, :may_show_soundcloud?
  alias_method :may_destroy_soundcloud?, :may_show_soundcloud?
end
