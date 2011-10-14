class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    if logged_in? && current_user.moderates? && !may_admin_site?
      render(:partial => '/admin/moderation_top_menu')
    end
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if logged_in? && current_user.moderates?
  end

  def group_permissions(context)
    return unless context[:group].council?
    return if context[:form].nil?
    f=context[:form]
    f.row do |r|
      r.label I18n.t(:moderation)
      r.checkboxes do |list|
        admins_may_moderate_checkbox(list)
      end
    end
  end
end
