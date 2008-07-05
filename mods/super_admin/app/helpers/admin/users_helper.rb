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

end


