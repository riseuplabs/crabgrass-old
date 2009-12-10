class Admin::AccountController < Admin::BaseController

  permissions 'admin/super'

  # make an admin user assume the identity of another user
  def become
    @user = User.find(params[:id])
    session[:user] = @user.id
    session[:admin] = current_user.id
    redirect_to '/'
  end

end

