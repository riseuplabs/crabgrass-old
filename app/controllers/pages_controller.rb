=begin

PagesController
---------------------------------

If you have an actual page, then the controller that controls it is BasePageController
or one of the many subclasses of this controller (one for each page type).

This controller, on the other hand, is for cases when we don't have an actual
page or you don't know the page type in question.

For example, the new() action in PagesControllers handles the first step where
you choose a page type. The next step where you enter in data is handled by
BasePageController so that each tool can define their own method of creation.

The index() action can be triggered through restful routing as in
 /pages
or through the seperate routing with paths as in
 /pages/tag/important
Some paths will be caught by their own controllers before hand though. For
example
 /pages/my_work

Restful routing interprets posts as create action. This controller turns them
into paths and then redirects.

=end

class PagesController < ApplicationController

  before_filter :login_required, :except => [:search]
  stylesheet 'page_creation', :action => :new
  permissions 'pages'

  # if this controller is called by DispatchController,
  # then we may be passed some objects that are already loaded.
  def initialize(options={})
    super()
    @pages = options[:pages] # a list of pages, if already fetched
  end

  # a simple form to allow the user to select which type of page
  # they want to create. the actual create form is handled by
  # BasePageController (or overridden by the particular tool).
  def new
    @available_tools = (@group && @group.group_setting.allowed_tools ? @group.group_setting.allowed_tools : current_site.available_page_types)
  end

  # Posts are interpreted as create by the restful side of things
  # So we turn them into a path.
  # Think: This creates a new view on the collection of pages.
  def create
    path = parse_filter_path(params[:search])
    redirect_to pages_url + path
  end

  # This is a workaround as long as we do not have :only => :index for resources.
  # Then the /pages/single_item_path routes would point to index anyway.
  def show
    @path=params[:id]
    index
  end

  def index
    @path.default_sort('updated_at')
    @pages = Page.paginate_by_path(@path, options_for_me(:page => params[:page]))
    add_user_participations(@pages)
    handle_rss(
      :title => current_user.name + ' ' + I18n.t(:my_work_link),
      :link => my_work_path,
      :image => avatar_url(:id => @user.avatar_id||0, :size => 'huge')
    ) or render(:action => 'list')
  end

  protected

  def context
    return true unless request.get? # skip the context on posts, it won't be shown anyway
    @group ||= Group.find_by_name(params[:group_id]) if params[:group_id]
    @group ||= Group.find_by_name(params[:group]) if params[:group]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user
    page_context
    context_name = I18n.t(:create_a_new_thing, :thing => I18n.t(:page)).titleize
    add_context(context_name, :controller => 'pages', :action => 'create', :group => params[:group])
    true
  end

end
