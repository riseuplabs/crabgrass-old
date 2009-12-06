=begin

PagesController
---------------------------------

If you have an actual page, then the controller that controls it is BasePageController
or one of the many subclasses of this controller (one for each page type).

This controller, on the other hand, is for cases when we don't have an actual
page or you don't know the page type in question.

For example, there are two create() actions, one in PagesControllers
and one in BasePageController. The one in PagesController handles the first
step where you choose a page type. The one in BasePageController handles the
next step where you enter in data. This step is handled by BasePageController
so that each tool can define their own method of creation.

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

  # display a list of pages when the url is ambiguous about which one to show.
  # login is not required.
  def search
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
