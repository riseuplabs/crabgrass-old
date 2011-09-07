class SoundcloudListener < Crabgrass::Hook::ViewListener
  include Singleton

  def admin_nav(context)
    render(:partial => '/admin/soundcloud_nav') if may_admin_site?
  end
end
