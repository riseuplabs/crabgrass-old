class MeController < Me::BaseController

  def index
    flash.keep
    redirect_to :controller => '/me/dashboard'
  end

  def edit
    if request.post?
      if @user.update_attributes(params[:user])
        flash_message :success => 'Your profile was successfully updated.'
        redirect_to me_url(:action => 'edit')
      else
        flash_message_now :object => @user
      end
    end
  end

  def counts
    return false unless request.xhr?
    @from_me_count = 0 #Request.created_by(current_user).pending.count
    @to_me_count   = Request.to_user(current_user).pending.count
    @unread_count  = Page.count_by_path('unread',  options_for_inbox(:do => { :what => { :we =>  :want}}))
    render :layout => false
  end

  def delete_avatar
    @user.kill_avatar
    render :text => avatar_for(@user,"x-large")
  end

  def recent_pages
    return false unless request.xhr?
    @recent_pages_list = current_user.pages.recent_pages
  end

  protected

  def context
    super
    unless ['show','index'].include?(params[:action])
      # url_for is used here instead of me_url so we can include the *path in the link
      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
      # that it is. regardless, we want it.)
      add_context params[:action], url_for(:controller => '/me/', :action => params[:action])
    end
  end

end
