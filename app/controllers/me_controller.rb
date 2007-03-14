class MeController < ApplicationController

  append_before_filter :fetch_user
  
  def index
    @pages = @user.participations.find(:all, :include=>'page', :order => 'pages.updated_at DESC')
  end

  def folder
    path = params[:path]
    conditions = ["1"]
    values = []
    if path.first == 'unread'
      conditions << 'viewed = ?'
      values << false
    elsif path.first == 'pending'
      conditions << 'user_participations.resolved = ?'
      values << false
    elsif path.first == 'upcoming'
      conditions << 'pages.happens_at > ?'
      values << Time.now
    end
    @cond = [conditions.join(' AND ')] + values
    @pages = @user.participations.find(
      :all,
      :conditions => @cond,
      :include=>'page',
      :order => 'pages.updated_at DESC'
    )
    render :action => 'index'
  end

  def edit
    
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
  
  def fetch_user
    @user = current_user
  end
  
  def breadcrumbs
    add_crumb 'me', me_url(:action => 'index')
    unless ['show','index'].include?(params[:action])
      add_crumb params[:action], me_url(:action => params[:action])
    end
  end
end
