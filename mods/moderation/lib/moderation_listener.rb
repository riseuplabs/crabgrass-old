class ModerationListener < Crabgrass::Hook::ViewListener
  include Singleton

  def top_menu(context)
    if logged_in? && current_user.moderator?
    content_tag(:li, content_tag(:span, link_to_active( "Moderation"[:menu_moderation],
                                                        { :controller => 'admin/pages' },
                                                        @active_tab == :moderation ) ),
                :class => (@active_tab == :moderation ? 'active' : ''))
    end
  end

  def admin_nav(context)
    render(:partial => '/admin/base/moderation_nav') if logged_in? && current_user.moderator?
  end
end
