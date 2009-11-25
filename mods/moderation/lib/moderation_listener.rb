class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    render(:partial => '/admin/moderation_top_menu') if logged_in? && current_user.moderates?
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if logged_in? && current_user.moderates?
  end

  def group_permissions(context)
    return if context[:group].council_id.nil?
    f=context[:form]
    f.row do |r|
      r.label I18n.t(:moderation)
      r.checkboxes do |list|
        admins_may_moderate_checkbox(list)
      end
    end
  end
end
