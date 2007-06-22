class GroupsController < ApplicationController
  layout :choose_layout
  stylesheet 'groups'
  
  prepend_before_filter :find_group, :except => ['list','create','index']
  skip_before_filter :login_required
  
  def index
    list
    render :action => 'list'
  end

  verify :method => :post,
    :only => [ :destroy, :add_user, :remove_user, :join_group, :leave_group ]

  def list
    #@group_pages, @groups = paginate :groups, :per_page => 10, :conditions => 'type IS NULL'
    @groups = Group.find :all, :conditions => 'type IS NULL'
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def show
    params[:path] = []
    search()
  end

  def archive
    sql = "SELECT MONTH(pages.created_at) AS month, " + 
     "YEAR(pages.created_at) AS year, count(pages.id) " +
     "FROM pages JOIN group_participations ON pages.id = group_participations.page_id " +
     "JOIN user_participations ON pages.id = user_participations.id " +
     "WHERE group_participations.group_id = #{@group.id} "
    unless current_user.member_of? @group
      sql += " AND (pages.public = 1 OR user_participations.user_id = #{current_user.id}) "
    end
    sql += "GROUP BY year, month ORDER BY year, month"
    @months = Page.connection.select_all(sql)
    
    unless @months.empty?
      @start_year = @months[0]['year'] 
      @current_year = (Date.today).year
      @current_month = (Date.today).month
      path = params[:path] || []
      parsed = parse_filter_path(params[:path])
      unless parsed.keyword?('month')
        path << 'month' << @current_month
      end
      unless parsed.keyword?('year')
        path << 'year' << @current_year
      end
      @pages, @page_sections = fetch_pages_from_path(path)
    end
  end
    
   
  def search
    @pages, @page_sections = fetch_pages_from_path(params[:path])
    render :action => 'show'
  end

  def tags
    tags = params[:path] || []
    path = tags.collect{|a|['tag',a]}.flatten
    @pages, @page_sections = fetch_pages_from_path(path)
  end

  def tasks
    @stylesheet = 'tasks'
    @pages, @page_sections = fetch_pages_from_path(['type','task','pending'])
    @task_lists = @pages.collect{|part|part.page.data}
  end

  def create
    @parent = Group.find(params[:parent_id]) if params[:parent_id]
    if @parent
      @group = Committee.new(params[:group])
      @group.parent = @parent
    else
      @group = Group.new(params[:group])
    end  
    if request.post?
      if @group.save
        message :success => 'Group was successfully created.'
        @group.users << current_user 
        redirect_to :action => 'show', :id => @group
      else
        message :object => @group
      end
    end
  end

  def edit
    if request.post? 
      if @group.update_attributes(params[:group])
        redirect_to :action => 'edit', :id => @group
        message :success => 'Group was successfully updated.'
      else
        message :object => @group
      end
    end
  end
  
  def edit_public_home
    unless @group.public_home
      page = Page.make :wiki, :group => @group, :user => current_user, :name => 'public home', :body => 'new public home'
      page.save!
      @group.public_home_id = page.data_id
      @group.save!
    else
      page = @group.public_home.page
    end
    redirect_to page_url(page, :action => 'edit')
  end
  
  def edit_private_home
    unless @group.private_home
      page = Page.make :wiki, :group => @group, :user => current_user, :name => 'private home', :body => 'new private home'
      page.save!
      @group.private_home_id = page.data_id
      @group.save!
    else
      page = @group.private_home.page
    end
    redirect_to page_url(page, :action => 'edit')
  end
  
  def update
    @group.update_attributes(params[:group])
    redirect_to :action => 'show', :id => @group
  end

  # an action to define the membership of a group. 
  # allows you to add people, remove them, see their status, invite people.
  def members
    if request.post?
      if @group.committee? and params[:group]
        @group.user_ids = params[:group][:user_ids] 
        @group.save
        message :success => 'member list updated'
      end
    end
  end
  

  def invite
    return(render :action => 'members') unless request.post?
    wrong = []
    sent = []
    params[:users].split(/\s/).each do |login|
      next if login.empty?
      if user = User.find_by_login(login)
        page = Page.make :invite_to_join_group, :group => @group, :user => user, :from => current_user
        page.save
        sent << login
      else
        wrong << login
      end
    end
    if wrong.any?
      message :later => true, :error => "These invites could not be sent because the user names don't exist: " + wrong.join(', ')
    elsif sent.any?
      message :success => 'Invites sent: ' + sent.join(', ')
    end
    redirect_to :action => 'members', :id => @group
  end
  
  # post only
  def add_user
    user = User.find_by_login params[:login]
    page = Page.make :invite_to_join_group, :user => user, :group => @group, :from => current_user
    if page.save
      message :success => "Invitation sent"
      redirect_to group_url(:action => 'edit', :id => group)
    else
      message :object => page
      render :action => 'edit'
    end
  end
  
  # post only
  def remove_user
    user = User.find_by_login params[:login]
    @group.users.delete(user)
    message :success => 'User %s removed from group %s'.t % [user.login, @group.name]
    redirect_to group_url(:action => 'edit', :id => @group)
  end
  
  # post only
  def join_group
    unless @group.users.any?
      # if the group has no users, then let the first person join.
      @group.users << current_user
      message :success => 'You are the first pers:rows => 8, :cols => 60on in this group'
      redirect_to :action => 'show', :id => @group
      return
    end
    page = Page.make :request_to_join_group, :user => current_user, :group => @group
    if page.save
      message :success => 'Your request to join this group has been sent.'
      page = Page.make :join_sent_notice, :user => current_user, :group => @group
      page.save
      redirect_to group_url(:action => 'show', :id => @group)
    else
      message :object => page
      render :action => 'show'
    end
  end
  
  # post only
  def leave_group
    current_user.groups.delete(@group)
    message :success => 'You have been removed from %s' / @group.name
    redirect_to me_url
  end
  
  # post only
  def destroy
    if @group.users.size > 1 or @group.users.first != current_user
      message :error => 'You can only delete a group if you are the last member'
      redirect_to :action => 'show', :id => @group
    else
      @group.destroy      
      redirect_to :action => 'list'
    end
  end  
     
  protected
  
  def choose_layout
     return 'application' if ['list','index'].include? params[:action]
     return 'groups'
  end
  
  def context
    group_context
    unless ['show','index','list'].include? params[:action]
      add_context params[:action], url_for(:controller=>'groups', :action => params[:action], :id => @group, :path => params[:path])
      # url_for is used here to capture the path
    end
  end
  
  def find_group
    @group = Group.get_by_name params[:id].sub(' ','+') if params[:id]
    if @group
      @group_type = @group.class.to_s.downcase
      return true
    else
      render :action => 'not_found'
      return false
    end
  end
  
  def authorized?
    members_only = %w(destroy leave_group remove_user add_user invite edit edit_home update members)
    if members_only.include? params[:action]
      return(logged_in? and current_user.member_of? @group)
    else
      return true
    end
  end
  
  def fetch_pages_from_path(path)
    options = {:class => GroupParticipation, :path => path}
    if logged_in?
      # the group's pages that we also have access to
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [@group.id, current_user.group_ids, current_user.id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [@group.id, true]
    end
    find_and_paginate_pages options
  end
  
end
