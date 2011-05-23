module Admin::UsersHelper

  def user_path(arg, options={})
    admin_user_path(arg,options)
  end

  def edit_user_path(arg)
    edit_admin_user_path(arg)
  end

  def new_user_path
    new_admin_user_path
  end

  def users_path
    admin_users_path
  end

  def user_url(arg, options={})
    admin_user_url(arg, options)
  end

  def users_heading
    show = params[:show] ? (params[:show]+' ') : ''
    'Edit ' + show.capitalize + 'Users'
  end

  def letter_pagination_url
    show = params[:show] ? {:show => params[:show]} : {}
    {:controller => '/admin/users'}.merge(show)
  end

  def filter_users_selected(arg)
    return 'selected' if arg == params[:show]
  end

  def total_users_heading
    case params[:show]
      when "active" then " active within the last month"
      when "inactive" then " not active within the last month"
      else ''
    end
  end

end


