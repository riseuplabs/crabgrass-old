=begin

This is the controller that all page controllers are based on.

=end

class BasePageController < ApplicationController

  layout :choose_layout
  stylesheet 'page', 'post'

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

  ##
  ## CREATION
  ## 
    
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
    @stylesheet = 'page_creation'
    render :template => 'base_page/create'
  end

  def destroy
    url = from_url(@page)
    @page.destroy
    redirect_to url
  end
  
  protected

  def authorized?
    if @page
      if params[:action] == 'show_popup'
        return true
      else
        current_user.may?(:admin, @page)
      end
    else
      true
    end
  end

  def choose_layout
    return 'default' if params[:action] == 'create'
    return 'page'
  end
  
  def update_participation
    if logged_in? and @page and params[:action] == 'show'
      current_user.viewed(@page)
    end
  end
  
  def setup_default_view
    if request.get?
      setup_view        # allow subclass to override view defaults
      @show_posts       = params[:action] == 'show' if @show_posts.nil?
      @show_reply       = @posts.any? if @show_reply.nil?
      @show_attachments = true if @show_attachments.nil?
      @show_tags        = true if @show_tags.nil? 
      @html_title       = @page.title if @page
      unless params[:action] == 'create'
        @title_box        = '<div id="title">%s</div>' % render_to_string(:partial => 'base_page/title/title') if @title_box.nil?
      end
      if params[:action] == 'show' or params[:action] == 'edit'
        @right_column     = render_to_string :partial => 'base_page/sidebar' if @right_column.nil?
      end
    end
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
    
  def fetch_page_data
    return true unless @page or params[:page_id]
    unless @page
      # typically, @page will be loaded by the dispatch controller. 
      # however, in some cases (like ajax) we bypass the dispatch controller
      # and need to grab the page here.
      @page = Page.find(params[:page_id])
    end
    # grab the current user's participation from memory
    @upart = (@page.participation_for_user(current_user) if logged_in?)

    unless request.xhr?
      @page.discussion ||= Discussion.new    
      disc = @page.discussion
      current_page = params[:posts] || disc.last_page
      @post_paging = Paginator.new self, disc.posts.count, disc.per_page, current_page
      @posts = disc.posts.find(:all, :include => 'ratings', :limit => disc.per_page, :offset => @post_paging.current.offset)
      @post = Post.new
    end
    true
  end
      
  def context
    return true if request.xhr?
    @group ||= Group.find_by_id(params[:group_id]) if params[:group_id]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    if !@group and !@user and params[:action] == 'create'
      @user = current_user     
      me_context('large')
      add_context 'create', url_for(:controller => params[:controller], :action => 'create', :id => params[:id])
    else
      page_context
    end
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
        page.set_tag_list params[:tag_list]
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
