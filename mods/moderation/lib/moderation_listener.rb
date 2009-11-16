class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    render(:partial => '/admin/moderation_top_menu') if show_nav_elements?
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if show_nav_elements?
  end

  protected
  def show_nav_elements?
    logged_in? && current_user.moderator?(current_site)
  end
end
