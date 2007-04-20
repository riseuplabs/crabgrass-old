class MeController < ApplicationController

  append_before_filter :fetch_user
  
  def index
    params[:path] = []
    inbox
  end

  def inbox
    path = params[:path]
    path = ['starred','or','unread','or','pending'] if path.first == 'vital'
    options = {
      :class => UserParticipation,
      :path => path,
      :conditions => 'user_participations.user_id = ?',
      :values => [current_user.id]
    }
    @pages, @page_sections = find_and_paginate_pages(options)
  end

  def tasks
    @stylesheet = 'tasks'
    # eager load everything we will need to show tasks (pages, tasks, users)
    @task_lists = Task::TaskList.find(:all, :conditions => ['users.id = ? AND tasks.completed = ?',current_user.id,false], :include => [:pages, {:tasks => :users}])
  end
 
  def edit   
    if request.post? 
      if @user.update_attributes(params[:user])
        redirect_to :action => 'edit'
        message :success => 'Your profile was successfully updated.'
      else
        message :object => @user
      end
    end
  end

  #def avatar
  #  if request.post?
  #    avatar = Avatar.create(:data => params[:image][:data])
  #    if avatar.valid?
  #      @user.avatar.destroy if @user.avatar
  #      @user.avatar = avatar
  #      @user.save
  #      redirect_to :action => 'edit'
  #      return
  #    end
  #  end
  #  render :action => 'edit'
  #end
  
  protected
  
  def fetch_user
    @user = current_user
  end
  
  def breadcrumbs
    add_crumb 'me', me_url(:action => 'index')
    #unless ['show','index'].include?(params[:action])
    #  add_crumb params[:action], me_url(:action => params[:action])
    #end
    set_banner 'me/banner', current_user.style
  end
end
