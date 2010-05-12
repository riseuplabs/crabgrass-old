class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    #render(:partial => '/admin/moderation_top_menu') if show_nav_elements?
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if show_nav_elements?
  end

  def group_permissions(context)
    return if context[:group].council_id.nil?
    return if context[:form].nil?
    f=context[:form]
    f.row do |r|
      r.label I18n.t(:moderation)
      r.checkboxes do |list|
        admins_may_moderate_checkbox(list)
      end
    end
  end

  protected
  def show_nav_elements?
    logged_in? && current_user.moderator?(current_site)
  end
end
