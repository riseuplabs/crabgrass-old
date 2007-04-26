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

  def search
    options = options_for_pages_viewable_by(current_user)
    @pages, @page_sections = find_and_paginate_pages(options, params[:path])
  end
  
  def tasks
    @stylesheet = 'tasks'
    filter = params[:id] || 'my-pending'
    if filter =~ /^all-(.*)/
      completed = $1 == 'completed'
      options = options_for_pages_viewable_by(current_user)
      @pages = find_pages(options, 'type/task')
      @task_lists = @pages.collect{|page|page.data}
      @show_user = 'all'
      @show_status = completed ? 'completed' : 'pending'
    elsif filter =~ /^group-(.*)/
      # show tasks from a particular group
      groupid = $1
      options = options_for_pages_viewable_by(current_user)
      @pages = find_pages(options, "type/task/group/#{groupid}")
      @task_lists = @pages.collect{|page|page.data}
      @show_user = 'all'
      @show_status = 'pending'
    elsif filter =~ /^my-(.*)/
      # show my completed or pending tasks
      completed = $1 == 'completed'
      include = [:pages, {:tasks => :users}] # eager load all we will need to show the tasks.
      conditions = ['users.id = ? AND tasks.completed = ?', current_user.id, completed]
      @task_lists = Task::TaskList.find(:all, :conditions => conditions, :include => include)
      @show_user = current_user
      @show_status = completed ? 'completed' : 'pending'
    end
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

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
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
