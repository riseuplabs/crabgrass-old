class Me::SettingsController < Me::BaseController

  def show
  end

  def update
    if current_user.update_attributes(params[:user])
      flash_message :success
      redirect_to me_settings_url
    else
      flash_message :object => current_user
      render :action => "show"
    end
  end

end
