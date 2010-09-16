
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

  def default_path_finder_options(context)
    return false if !current_user.superadmin?
    # currently only want to overwrite data for groups
    return if context[:group].nil?
    options = {}
    options[:group_ids] = [ context[:group].id ]
    options[:public] = false
    options[:user_ids] = false
    return options
  end

  def default_requests_view(context)
    return "all" if current_user.superadmin? 
  end

  def requests_views_options(context)
    return {} if !current_user.superadmin?
    {:view => [{:name => :all, :translation => :all_admin_requests},
                {:name => :to_me, :translation => :requests_to_me},
                {:name => :from_me, :translation => :requests_from_me}]
    }
  end

end
