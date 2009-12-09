=begin

This is the controller that all page controllers are based on.

=end

class BasePageController < ApplicationController

  include BasePageHelper
  layout :choose_layout
  stylesheet 'page_creation', :action => :create
  javascript 'page'
  permissions 'base_page', 'posts'
  helper 'groups', 'autocomplete', 'base_page/share', 'page_history'

  # page_controller subclasses often need to run code at very precise placing
  # in the filter chain. For this reason, there are a number of stub methods
  # they can define:
  #
  # filter order:
  # (1) fetch_page_data
  # (2) fetch_data (defined by subclass)
  # (3) setup_view (defined by subclass)
  # (4) setup_default_view

  prepend_before_filter :fetch_page_data
  append_before_filter :login_or_public_page_required
  append_before_filter :setup_default_view
  append_before_filter :load_posts
  # :load_posts should come after :setup_default_view, to give controllers an
  # opportunity to disable loading of posts or to load posts via an alternate
  # method.

  # if the page controller is call by our custom DispatchController,
  # objects which have already been loaded will be passed to the tool
  # via this initialize method.
  def initialize(options={})
    super()
    @user = options[:user]   # the user context, if any
    @group = options[:group] # the group context, if any
    @page = options[:page]   # the page object, if already fetched
  end

  ##
  ## CREATION
  ##

  # the form to create this type of page
  # can be overridden by the subclasses
  def create
    @page_class = get_page_type
    @page = build_new_page(@page_class)

    if params[:cancel]
      return redirect_to(create_page_url(nil, :group => params[:group]))
    elsif request.post?
      begin
        # setup the data (done by subclasses)
        @data = build_page_data
        raise ActiveRecord::RecordInvalid.new(@data) if @data and !@data.valid?

        # save the page (also saves the data)
        @page.data = @data
        @page.save!

        return redirect_to(page_url(@page))
      rescue Exception => exc
        destroy_page_data
        # in case page gets saved before the exception happens
        @page.destroy unless @page.new_record?
        flash_message_now :exception => exc
      end
    end
  end

  def page_history
  end

  protected


  def choose_layout
    return 'default' if params[:action] == 'create'
    return 'page'
  end

  after_filter :update_viewed, :only => :show
  def update_viewed
    if @upart and @page
      @upart.viewed_at = Time.now
      @upart.notice = nil
      @upart.viewed = true
    end
    true
  end

  after_filter :save_if_needed, :except => :create
  def save_if_needed
    @upart.save if @upart and !@upart.new_record? and @upart.changed? and !@upart.readonly?
    @page.save if @page and !@page.new_record? and @page.changed? and !@page.readonly?
    true
  end

  after_filter :update_view_count, :only => [:show, :edit, :create]
  def update_view_count
    return true unless @page and @page.id
    action = case params[:action]
      when 'create' then :edit
      when 'edit' then :edit
      when 'show' then :view
    end
    return true unless action

    group = current_site.tracking? && @group
    group ||= current_site.tracking? && @page.owner.is_a?(Group) && @page.owner
    user  = current_site.tracking? && @page.owner.is_a?(User) && @page.owner
    Tracking.insert_delayed(
      :page => @page, :current_user => current_user, :action => action,
      :group => group, :user => user
    )
    true
  end

  def setup_default_view
    if request.get?
      setup_view        # allow subclass to override view defaults
      @show_posts       = action?(:show) || action?(:print) if @show_posts.nil?
      @show_attachments = true           if @show_attachments.nil?
      @show_tags        = true           if @show_tags.nil?
      @html_title       = @page.title    if @page && @html_title.nil?

      # show the right column in actions other than :show,:edit
      @show_right_column = false if @show_right_column.nil?

      # hide the right column
      @hide_right_column = false if @hide_right_column.nil?
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
    fetch_data() # all subclasses to get fetch data early on.
    true
  end

  # to be overwritten by subclasses.
  def fetch_data
  end

  def load_posts
    return if @discussion === false || @page.nil? # allow for the disabling of load_posts()
    @discussion ||= (@page.discussion ||= Discussion.new)
    current_page = params[:posts] || @discussion.last_page
    @posts = Post.visible.paginate_by_discussion_id(@discussion.id,
      :order => "created_at ASC", :page => current_page,
      :per_page => @discussion.per_page, :include => :ratings)
    @post = Post.new
    @show_reply = @posts.any? if @show_reply.nil?
  end

  def context
    if action?(:create)
      @group = Group.find_by_name(params[:group])
      @user = current_user
      page_context

      context_name = I18n.t(:create_a_new_thing, :thing => get_page_type.class_display_name).titleize
      add_context context_name, :controller => params[:controller], :action => 'create', :id => params[:id], :group => params[:group]
    else
      page_context
      @title_box = '<div id="title" class="page_title shy_parent">%s</div>' % render_to_string(:partial => 'base_page/title/title') if @title_box.nil? && @page
      if !@hide_right_column and (action?(:show,:edit) or @show_right_column)
        @right_column = render_to_string :partial => 'base_page/sidebar' if @right_column.nil?
      end
    end
    true
  end

  ##
  ## default page creation methods used by tool controllers
  ##

  def get_page_type(param=nil)
    param ||= params[:id]
    raise 'page type required' unless param
    return Page.param_id_to_class(param)
  end

  def build_new_page(page_class)
    params[:page] ||= HashWithIndifferentAccess.new
    params[:page][:user] = current_user
    params[:page][:share_with] = params[:recipients]
    params[:page][:access] = case params[:access]
      when 'admin' then :admin
      when 'edit'  then :edit
      when 'view'  then :view
      else Conf.default_page_access
    end
    page_class.build!( params[:page].dup )
  end

  # returns a new data object for page initialization
  # tools override this to build their own data objects
  def build_page_data
    # if something goes terribly wrong with the data do this:
    # @page.errors.add_to_base I18n.t(:terrible_wrongness)
    # raise ActiveRecord::RecordInvalid.new(@page)

    # return new data if everything goes well
  end

  def destroy_page_data
    if @data and !@data.new_record?
      @data.destroy
    end
  end

end

