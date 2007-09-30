class GroupsController < ApplicationController
  layout :choose_layout
  stylesheet 'groups'
  
  prepend_before_filter :find_group, :except => ['list','create','index']
  
  before_filter :login_required,
    :only => [:create, :edit, :edit_public_home, :edit_private_home, :destroy, :update]

  verify :method => :post,
    :only => [:destroy, :update ]

  def initialize(options={})
    super()
    @group = options[:group] # the group context, if any
  end  
  
  def index
    list
    render :action => 'list'
  end

  def list
    @groups = Group.find :all, :conditions => 'type IS NULL'
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")
  end

  def show
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
      @pages, @sections = fetch_pages_from_path(path)
    end
  end
  
  def search
    if request.post?
      path = build_filter_path(params[:search])
      redirect_to groups_url(:id => @group, :action => 'search') + path   
    else
      @pages, @sections = fetch_pages_from_path(params[:path])
      if parsed_path.sort_arg?('created_at') or parsed_path.sort_arg?('created_by_login')    
        @columns = [:icon, :title, :created_by, :created_at, :contributors_count]
      else
        @columns = [:icon, :title, :updated_by, :updated_at, :contributors_count]
      end
    end

    handle_rss :title => @group.name, :description => @group.summary,
               :link => url_for_group(@group),
               :image => avatar_url(:id => @group.avatar_id||0, :size => 'huge')
  end
  
  def tags
    tags = params[:path] || []
    path = tags.collect{|a|['tag',a]}.flatten
    @pages, @sections = fetch_pages_from_path(path)
  end

  def tasks
    @stylesheet = 'tasks'
    @pages, @sections = fetch_pages_from_path(['type','task','pending'])
    @task_lists = @pages.collect{|part|part.page.data}
  end

  # login required
  def create
    set_banner "groups/banner_search", Style.new(:background_color => "#1B5790", :color => "#eef")
    @parent = Group.find(params[:parent_id]) if params[:parent_id]
    if @parent
      @group = Committee.new(params[:group])
      unless logged_in? and current_user.member_of?(@parent)
        message( :error => 'you do not have permission to do that', :later => true )
        redirect_to url_for_group(@parent)
      end
      @group.parent = @parent
    else
      @group = Group.new(params[:group])
    end  
    if request.post?
      if @group.save
        message :success => 'Group was successfully created.'
        @group.memberships.create :user => current_user
        redirect_to url_for_group(@group)
      else
        message :object => @group
      end
    end
  end

  # login required
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
  
  # login required
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
  
  # login required
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
  
  # login required
  # post required
  def update
    @group.update_attributes(params[:group])
    redirect_to :action => 'show', :id => @group
  end
  
  # login required
  # post required
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
     return 'application' if ['list','index', 'create'].include? params[:action]
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
    non_members_post_allowed = %w(archive search tags tasks create)
    non_members_get_allowed = %w(show members) + non_members_post_allowed
    if request.get? and non_members_get_allowed.include? params[:action]
      return true
    elsif request.post? and non_members_post_allowed.include? params[:action]
      return true
    else
      return(logged_in? and current_user.member_of? @group)
    end
  end
  
  def fetch_pages_from_path(path)
    options = {:class => GroupParticipation, :path => path}
    if logged_in?
      # the group's pages that we also have access to
      # we might not be in a group, but still have access one of the group's
      # pages via our membership in another group.
      options[:conditions] = "(group_participations.group_id = ? AND (group_parts.group_id IN (?) OR user_parts.user_id = ? OR pages.public = ?))"
      options[:values]     = [@group.id, current_user.all_group_ids, current_user.id, true]
    else
      # the group's public pages
      options[:conditions] = "group_participations.group_id = ? AND pages.public = ?"
      options[:values]     = [@group.id, true]
    end
    find_and_paginate_pages options
  end
  
end
