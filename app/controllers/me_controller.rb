class MeController < Me::BaseController

  def show
    flash.keep
    redirect_to :controller => '/me/pages'
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash_message :success => 'Your profile was successfully updated.'
    else
      flash_message_now :object => @user
    end
    redirect_to edit_me_url
  end

  protected

  def context
    super
    unless ['show'].include?(params[:action])
      # url_for is used here instead of me_url so we can include the *path in the link
      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
      # that it is. regardless, we want it.)
      add_context params[:action], url_for(:controller => '/me/', :action => params[:action])
    end
  end

end
