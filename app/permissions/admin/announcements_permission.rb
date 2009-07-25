module Admin::AnnouncementsPermission

  # TODO: we might want a more fine grained permission structure
  # for group announcements. Currently site admins can create
  # announcements for all groups and destroy them as well.

  def may_index_announcements?
    may_admin_site?
  end

  def may_destroy_announcements?(page=nil)
    if page.nil?
      @page = Page.find_by_id(params[:id])
      return false unless page = @page
    end
    page.is_a?(AnnouncementPage) and
    may_index_announcements?
  end

  alias_method :may_create_announcements?, :may_index_announcements?
  alias_method :may_edit_announcements?, :may_index_announcements?
end
