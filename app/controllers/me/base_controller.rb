class Me::BaseController < ApplicationController
 
  before_filter :login_required
  stylesheet 'me'
  permissions 'me'

  def index
    redirect_to :controller => '/me/dashboard'
  end
  
  def edit   
    if request.post? 
      if @user.update_attributes(params[:user])
        flash_message :success => 'Your profile was successfully updated.'
        redirect_to :action => 'edit'
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

  protected
  
  def authorized?
    true
  end

  append_before_filter :fetch_user
  def fetch_user
    @user = current_user
  end
  
  before_filter :load_partials
  def load_partials
   @left_column = render_to_string :partial => 'me/sidebar'
  end

  def context
    me_context('large')
    unless ['show','index'].include?(params[:action])
      # url_for is used here instead of me_url so we can include the *path in the link
      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
      # that it is. regardless, we want it.)
      add_context params[:action], url_for(:controller => '/me/', :action => params[:action])
    end
  end
  
end
