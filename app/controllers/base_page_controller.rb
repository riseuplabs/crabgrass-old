=begin

This is the controller that all page controllers are based on.

=end

class BasePageController < ApplicationController

  layout :choose_layout
  stylesheet 'page', 'post'
  javascript 'page'

  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  append_before_filter :setup_default_view
  
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
    @page_class = get_page_type
    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        @page = create_new_page!(@page_class)
        return redirect_to(page_url(@page))
      rescue Exception => exc
        @page = exc.record
        flash_message_now :exception => exc
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
    if @page.nil?
      true
    elsif action?(:show_popup)
      true
    elsif action?(:show)
      current_user.may?(:view, @page)
    else
      current_user.may?(:admin, @page)
    end
  end

  def choose_layout
    return 'default' if params[:action] == 'create'
    return 'page'
  end
  
  after_filter :update_viewed
  def update_viewed
    if @upart and @page and params[:action] == 'show'
      @upart.viewed_at = Time.now
      @upart.notice = nil
      @upart.viewed = true
    end
    true
  end
  
  after_filter :save_if_needed
  def save_if_needed
    @upart.save if @upart and @upart.changed?
    @page.save if @page and @page.changed?
    true
  end
  
  after_filter :update_view_count
  def update_view_count
    PageView.insert_delayed(@page) if @page && !@page.id.nil?
  end
  
  def setup_default_view
    if request.get?
      setup_view        # allow subclass to override view defaults
      @show_posts       = action?(:show) if @show_posts.nil?
      @show_reply       = @posts.any?    if @show_reply.nil?
      @show_attachments = true           if @show_attachments.nil?
      @show_tags        = true           if @show_tags.nil? 
      @html_title       = @page.title    if @page && @html_title.nil?

      # show the right column in actions other than :show,:edit
      @show_right_column = false if @show_right_column.nil?

      # hide the right column 
      @hide_right_column = false if @hide_right_column.nil?

      unless action?(:create)
        @title_box = '<div id="title" class="page_title">%s</div>' % render_to_string(:partial => 'base_page/title/title') if @title_box.nil? && @page
      end
      if !@hide_right_column and (action?(:show,:edit) or @show_right_column)
        @right_column = render_to_string :partial => 'base_page/sidebar' if @right_column.nil?
      end
    end
    true
  end
  
  # to be overwritten by subclasses.
  def setup_view
  end
  
  # don't require a login for public pages
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

    if request.get?
      load_posts
    end
    true
  end

  def load_posts
    @page.discussion ||= Discussion.new    
    disc = @page.discussion
    current_page = params[:posts] || disc.last_page
    @posts = Post.paginate_by_discussion_id(disc.id,
      :order => "created_at ASC", :page => current_page,
      :per_page => disc.per_page, :include => :ratings)
    @post = Post.new
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
  
  ##
  ## default page creation methods used by tool controllers
  ##
  
  def get_page_type(param=nil)
    param ||= params[:id]
    raise ErrorMessage.new('page type required') unless param
    return Page.display_name_to_class(param)
  end

  def create_new_page!(page_class)
     page_class.create!(params[:page].merge(
       :user => current_user,
       :share_with => params[:recipients],
       :access => (params[:access]||'view').to_sym
     ))  
  end
end

