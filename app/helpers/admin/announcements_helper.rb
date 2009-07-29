module Admin::AnnouncementsHelper

  def announcement_path(arg, options={})
    admin_announcement_path(arg,options)
  end

  def edit_announcement_path(arg)
    edit_admin_announcement_path(arg)
  end

  def new_announcement_path
    new_admin_announcement_path
  end

  def announcements_path
    admin_announcements_path
  end

  def announcement_url(arg, options={})
    admin_announcement_url(arg, options)
  end
end


