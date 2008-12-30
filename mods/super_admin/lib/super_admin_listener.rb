
class SuperAdminListener < Crabgrass::Hook::ViewListener
  include Singleton

  def footer_content(context)
    return unless logged_in?
    if current_user.superadmin? or session[:admin]
      content_tag :p, link_to('administration panel', '/admin')
    end
  end

  def top_menu(context)
    return unless logged_in?
    if current_user.superadmin? or session[:admin]
      content_tag(:li, content_tag(:span, link_to("Admin", '/admin')))
    end
  end

end

