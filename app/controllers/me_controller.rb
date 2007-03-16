class MeController < ApplicationController

  append_before_filter :fetch_user
  
  def index
    @pages = @user.participations.find(:all, :include=>'page', :order => 'pages.updated_at DESC')
  end

  def folder
    path = params[:path].reverse
    
    conditions = ['user_participations.user_id = ?']
    values = [current_user.id]
    include = :page
    
    folder = path.pop
    if folder == 'unread'
      conditions << 'viewed = ?'
      values << false
    elsif folder == 'pending'
      conditions << 'user_participations.resolved = ?'
      values << false
    elsif folder == 'upcoming'
      conditions << 'pages.happens_at > ?'
      values << Time.now
    elsif folder == 'ago'
      near = path.pop.to_i.days.ago
      far  = path.pop.to_i.days.ago
      conditions << 'pages.updated_at < ? and pages.updated_at > ? '
      values << near
      values << far
    elsif folder == 'type'
      page_class = tool_class_str(path.pop)
      conditions << 'pages.type IN (?)'
      values << page_class
    elsif folder == 'person'
      conditions << 'user_participations_pages.user_id = ?'
      values << path.pop
      include = [:page => :user_participations]
    end
    
    @cond = [conditions.join(' AND ')] + values
    @pages = UserParticipation.find(:all, 
      :all,
      :conditions => @cond,
      :include => include,
      :order => 'pages.updated_at DESC'
    )
    @folder = folder
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
