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
Some paths will be taken care of by collections before hand though. For
example
 /pages/my_work

Restful routing interprets posts as create action. This controller turns them
into paths and then redirects.

=end

class PagesController < ApplicationController

  before_filter :login_required, :except => [:search]
  stylesheet 'page_creation', :action => :new
  stylesheet 'messages'
  permissions 'pages', 'groups/base'
  helper 'action_bar', 'tab_bar', 'groups'
  layout 'header'

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
    @available_tools = current_site.tools_for(@group)
    @second_nav = 'pages'
  end

  # Posts are interpreted as create by the restful side of things
  # So we turn them into a path.
  # Think: This creates a new view on the collection of pages.
  def create
    path = parse_filter_path(params[:search])
    redirect_to me_pages_url + path
  end

  # This is a workaround as long as we do not have :only => :index for resources.
  def show
    @path = parse_filter_path(params[:id])
    index
  end

  def index
    @path = parse_filter_path(params[:path])
    if @path.empty?
      redirect_to my_work_me_pages_url
    else
      all
    end
  end

  def all
    params[:view] ||= 'networks'
    @path.default_sort('updated_at')
    fetch_pages_for @path
    rss_for_collection(all_me_pages_path, :all_pages_tab)
    render :action => "all"  #now it also works for the index action
  end

  def my_work
    params[:view] ||= 'work'
    path = parse_filter_path("/#{params[:view]}/#{current_user.id}")
    fetch_pages_for path
    rss_for_collection(my_work_me_pages_path, :my_work_tab)
  end

  def mark
    mark_as = params[:as].to_sym
    Page.flag_all(params[:pages], :as => mark_as, :by => current_user)
    params[:view] ||= 'work'
    path = parse_filter_path("/#{params[:view]}/#{current_user.id}")
    fetch_pages_for path
    render :action => action_from_referer, :layout => false
  end

  protected

  def context
    return true unless request.get? # skip the context on posts, it won't be shown anyway
    @group ||= Group.find_by_name(params[:group_id]) if params[:group_id]
    @group ||= Group.find_by_name(params[:group]) if params[:group]
    @user ||= User.find_by_id(params[:user_id]) if params[:user_id]
    @user ||= current_user
    page_context
    context_name = context_name_for_action
    add_context(context_name,
      :controller => 'pages', :action => params[:action], :group => params[:group])
    true
  end

  def context_name_for_action
    case params[:action]
    when 'new'
      I18n.t(:create_a_new_thing, :thing => I18n.t(:page)).titleize
    when 'index'; I18n.t(:all_pages_tab)
    when 'all'; I18n.t(:all_pages_tab)
    when 'my_work'; I18n.t(:my_work_tab)
    when 'notification'; I18n.t(:notification_tab)
    end
  end

  def fetch_pages_for(path)
    @pages = Page.paginate_by_path(path, options_for_me(:page => params[:page]))
    add_user_participations(@pages) if logged_in?
  end

  # given an array of pages, find the corresponding user_participation records
  # and associate each participtions with the correct page.
  # afterwards, page.flag[:user_participation] should hold current_user's
  # participation for page.
  def add_user_participations(pages)
    pages_by_id = {}
    pages.each do |page|
      pages_by_id[page.id] = page
    end
    uparts = UserParticipation.find :all,
      :conditions => ['user_id = ? AND page_id IN (?)', current_user.id, pages_by_id.keys]
    uparts.each do |part|
      pages_by_id[part.page_id].flag[:user_participation] = part
    end
  end

  def rss_for_collection(link, title)
    title=I18n.t(title) if title.is_a?(Symbol)
    handle_rss(
      :title => current_user.name + ' ' + title,
      :link => link,
      :image => avatar_url(:id => @user.try.avatar_id||0, :size => 'huge')
    )
  end

  def action_from_referer
    case referer
    when /me\/pages\/all/ then :all
    when /me\/pages\/my_work/ then :my_work
    else :my_work
    end
  end

end
