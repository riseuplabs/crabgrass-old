# super class controller for all page types

class Tool::BaseController < ApplicationController
  include ToolCreation

  layout :choose_layout
  
  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  skip_before_filter :login_required
  append_before_filter :setup_default_view
  append_after_filter :update_participation
  
  # if the tool controller is call by our custom DispatchController, 
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
    @group = options[:group] # the group context, if any
    @page = options[:page]   # the page object, if already fetched
  end  
    
  # the form to create this type of page
  # can be overridden by the subclasses
  def create
    @page_class = Page.display_name_to_class(params[:id])
    if request.post?
      @page = build_new_page
      if @page.save
        return redirect_to(page_url(@page))
      else
        message :object => @page
      end
    end
    render :template => 'tool/base/create'
  end
  
  def title
    return(redirect_to page_url(@page, :action => :show)) unless request.post?
    @page.title = params[:page][:title]
    @page.name = params[:page][:name].to_s.nameize if params[:page][:name].any?
    if @page.save
      redirect_to page_url(@page, :action => 'show')
    else
      message :object => @page
      @page.name = @page.original_name
      render :action => 'show'
    end
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
    @posts = disc.posts.find(:all, :limit => disc.per_page, :offset =>  @post_paging.current.offset)
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
  
end
