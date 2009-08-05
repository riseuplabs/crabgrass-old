class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    render(:partial => '/admin/moderation_top_menu') if logged_in? && current_user.moderator?
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if logged_in? && current_user.moderator?
  end
end
