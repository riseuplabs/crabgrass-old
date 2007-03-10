class MeController < ApplicationController

  def index
    @user = current_user
  end

  def urgent
    @user = current_user
    render :action => 'index'
  end
  
  def search
    @user = current_user
    render :action => 'index'
  end

  def edit
    @user = current_user
    if request.post? 
      if @user.update_attributes(params[:user])
        redirect_to :action => 'edit'
      else
        message :object => @user
      end
    end
  end

  def avatar
    if request.post?
      avatar = Avatar.create(:data => params[:image][:data])
      if avatar.valid?
        @user.avatar.destroy if @user.avatar
        @user.avatar = avatar
        @user.save
        redirect_to :action => 'edit'
      end
    end
    render :action => 'edit'
  end
  
  protected
  
  def breadcrumbs
    @user = current_user
    add_crumb 'me', me_url(:action => 'index')
    unless ['show','index'].include?(params[:action])
      add_crumb params[:action], me_url(:action => params[:action])
    end
  end
end
