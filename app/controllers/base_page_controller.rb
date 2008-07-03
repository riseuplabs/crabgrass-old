=begin

This is the controller that all page controllers are based on.

Actions should go here if a page controller may want to override
the default behavior. Otherwise, page stuff goes in pages_controller.rb

=end

class BasePageController < ApplicationController
  layout :choose_layout
  
  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  append_before_filter :setup_default_view
  append_after_filter :update_participation
  
  # if the page controller is call by our custom DispatchController, 
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
    @group = options[:group] # the group context, if any
    @page = options[:page]   # the page object, if already fetched

    @javascript_extra = true
  end  
    
  # the form to create this type of page
  # can be overridden by the subclasses
  def create
    @page_class = Page.display_name_to_class(params[:id])
    if request.post?
      @page = create_new_page(@page_class)
      if @page.valid?
        return redirect_to(page_url(@page))
      else
        message :object => @page
      end
    end
    render :template => 'base_page/create'
  end
  
  protected

  def choose_layout
    return 'application' if params[:action] == 'create'
    return 'page'
  end
  
  def update_participation
    if logged_in? and @page and params[:action] == 'show'
      current_user.viewed(@page)
    end
  end
  
  def setup_default_view
    @show_posts = (%w(show title).include?params[:action]) # default, only show comment posts for the 'show' action
    @show_reply = @posts.any? # by default, don't show the reply box if there are no posts
    @show_attach = false
    @show_tags = true
    @show_links = true
    @sidebar = true
    @html_title = @page.title if @page
    setup_view # allow subclass to override view
    true
  end
  
  # to be overwritten by subclasses.
  def setup_view
  end
  
  def login_or_public_page_required
    if action_name == 'show' and @page and @page.public?
      true
    else
      return login_required
    end
  end
  
  # this needs to be fleshed out for each action
  def authorized?
    if @page
      current_user.may?(:admin, @page)
    else
      true
    end
  end
  
  def fetch_page_data
    return true unless @page or params[:page_id]
    unless @page
      # typically, @page will be loaded by the dispatch controller. 
      # however, in some cases (like ajax) we bypass the dispatch controller
      # and need to grab the page here.
      @page = Page.find(params[:page_id])
    end
    return true if request.xhr?
    if logged_in?
      # grab the current user's participation from memory
      @upart = @page.participation_for_user(current_user) if logged_in?
    else
      @upart = nil
    end
    @page.discussion = Discussion.new unless @page.discussion
    
    disc = @page.discussion
    current_page = params[:posts] || disc.last_page
    @post_paging = Paginator.new self, disc.posts.count, disc.per_page, current_page
    @posts = disc.posts.find(:all, :include => 'ratings', :limit => disc.per_page, :offset => @post_paging.current.offset)
    @post = Post.new
    true
  end
      
  def context
    return true if request.xhr?
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user 
    page_context
    true
  end
  
  ##############################################################
  ## Page Creation

  def create_new_page(page_class=nil)
    page_type = page_class || get_page_type
    Page.transaction do
      page = page_type.create params[:page].merge({:created_by_id => current_user.id})
      if page.valid?
        add_participants!(page, params)
        page.tag_list = params[:tag_list] if params[:tag_list]
        page.save
      end
      page
    end
  end

  def add_participants!(page, options={})
    users     = get_users
    if (group = get_group(options))
      page.add(group, :access => :admin)
      users += group.users if options[:announce]
    end
    users.uniq.each do |u|
      if u.member_of? group
        page.add(u)
      else
        page.add(u, :access=>:admin)
      end
    end
  end

  def get_groups
    [get_group(params)]
  end

  def get_group(options = {})
    return unless options[:group_name].any? or options[:group_id].any?
    if options[:group_name]
      return Group.get_by_name(options[:group_name]) || raise(Exception.new('no such group %s' % options[:group_name]))
    end
    Group.find_by_id(options[:group_id])
  end
  
  def get_users
    [current_user]    
  end
  
  def get_page_type
    raise Exception.new('page type required') unless params[:id]
    return Page.display_name_to_class(params[:id])
  end

end
