class MeController < ApplicationController

  append_before_filter :fetch_user
  
  def index
    params[:path] = []
    dash
    render :action => 'dash'
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
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to me_url(:action => 'search') + path   
    else
      options = options_for_pages_viewable_by(current_user)
      @pages, @page_sections = find_and_paginate_pages(options, params[:path])
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:icon, :title, :group, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :group, :updated_by, :updated_at, :contributors_count]
      end
    end
  end
  
  def dash
    options = options_for_pages_viewable_by(current_user, :flow => [:membership,:contacts])
    path = "/type/request/pending/not_created_by/#{current_user.id}"
    @request_count = count_pages(options, path)
  end
  
  def files
    options = options_for_pages_viewable_by(current_user)
    @pages = find_pages(options, 'type/asset')
    @assets = @pages.collect {|page| page.data }
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
  
  protected

  # it is impossible to see anyone else's me page,
  # so no authorization is needed.
  def authorized?
    return true
  end
  
  def fetch_user
    @user = current_user
  end
  
  def context
    me_context('large')
    unless ['show','index'].include?(params[:action])
      # url_for is used here instead of me_url so we can include the *path in the link
      # (it might be a bug in me_url that this is not included, or it might be a bug in url_for
      # that it is. regardless, we want it.)
      add_context params[:action], url_for(:controller => 'me', :action => params[:action])
    end
  end
  
end

