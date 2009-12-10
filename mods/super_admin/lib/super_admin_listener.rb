
class SuperAdminListener < Crabgrass::Hook::ViewListener
  include Singleton

  def footer_content(context)
    return unless logged_in?
    if current_user.superadmin? or session[:admin]
      content_tag :p, link_to('administration panel', '/admin')
    end
  end

  def admin_nav(context)
    render(:partial => '/admin/base/super_admin_nav') if may_super?
  end

end
