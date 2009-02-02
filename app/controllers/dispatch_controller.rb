#
# We have a problem: every page type has a different controller. 
# This means that we either have to declare the controller somehow
# in the route, or use a special dispatch controller that will pass
# on the request to the page's controller.
# 
# We have it set up so that we can do both. A static route would look like:
#   
#   /groups/riseup/wiki/show/40/
# 
# A route using this dispatcher would look like this:
# 
#   /riseup/title+40
# 
# The second one is prettier, but perhaps it is slower? This remains to be seen.
# 
# the idea was taken from:
# http://www.agileprogrammer.com/dotnetguy/archive/2006/07/09/16917.aspx
# 
# the dispatcher handles urls in the form:
# 
# /:context/:page/:page_action/:id
# 
# :context can be a group name or user login
# :page can be the name of the page or "#{title}+#{page_id}"
# :page_action is the action that should be passed on to the page's controller
# :id is just there as a catch all id for extra fun in case the
#     page's controller wants it.
#
#
# TODO: I think the dispatchController breaks flash hash. Fix it!
# 

class DispatchController < ApplicationController

  def process(request, response, method = :perform_action, *arguments)
    super(request, response, :dispatch)
  end

  def dispatch
    begin
      find_controller.process(request, response)
    rescue ActiveRecord::RecordNotFound
      @user = current_user
      @site = Site.default
      set_language do
        render :action => "not_found", :status => :not_found
      end
    end
  end

  private
  
  #
  # attempt to find a page by its name, and return a new instance of the
  # page's controller.
  # 
  # there are possibilities:
  # 
  # - if we can find a unique page, then show that page with the correct controller.
  # - if we get a list of pages
  #   - show either a list of public pages (if not logged in)
  #   - a list of pages current_user has access to
  # - if we fail entirely, show the page not found error.
  # 

  def find_controller
    page_handle = params[:_page]
    context = params[:_context]

    if context
      if context =~ /\ /
        # we are dealing with a committee!
        context.sub!(' ','+')
      end
      @group = Group.find_by_name(context) 
      @user  = User.find_by_login(context) unless @group
    end

    if page_handle.nil?
      return controller_for_group(@group) if @group
      return controller_for_people if @user
      raise ActiveRecord::RecordNotFound.new
    elsif page_handle =~ /[ +](\d+)$/
      # if page handle ends with [:space:][:number:] then find by page id.
      # (the url actually looks like "page-title+52", but pluses are interpreted
      # as spaces). find by id will always return a globally unique page so we
      # can ignore context
      @page = find_page_by_id( $~[1] )
    elsif @group
      # find just pages with the name that are owned by the group
      # no group should have multiple pages with the same name
      @page = find_page_by_group_and_name(@group, page_handle)
    else
      if @user
        @pages = find_pages_by_user_and_name(@user, page_handle)
      else
        @pages = find_pages_with_unknown_context(page_handle)
      end
      if @pages.size == 1
        @page = find_page_by_id( @pages.first.id )
      elsif @pages.any?
        # show a list of pages if more than one was found
        return controller_for_list_of_pages(page_handle)
      end
    end

    raise ActiveRecord::RecordNotFound.new unless @page
    return controller_for_page(@page)
  end
  
  # create a new instance of a controller, and pass it whatever info regarding
  # current group or user context or page object that we have gathered.
  def new_controller(class_name)
    class_name.constantize.new({:group => @group, :user => @user, :page => @page, :pages => @pages})
  end
  
  def includes(default=nil)
    # for now, every time we fetch a page we suck in all the groups and users
    # associated with the page. we only do this for GET requests, because
    # otherwise it is likely that we will not need the included data.
    
    # update: i think this is a big waste of time. checking the logs, group
    # and user participations are fetched independently despite this attempt
    # at including them with the page query -elijah

    #if request.get?
    #  [{:user_participations => :user}, {:group_participations => :group}]
    #else
    #  return default
    #end
    nil
  end
  
  def find_page_by_id(id)
    Page.find_by_id(id.to_i, :include => includes )
  end
  
  # almost every page is fetched using this function
  # we attempt to load the page using the group directly. 
  # if that fails, then we resort to searching the entire
  # page namespace.
  def find_page_by_group_and_name(group, name)
    page = group.pages.find(:first, :conditions => ['pages.name = ?',name])
    return page if page
    ids = Group.namespace_ids(group.id)
    Page.find(:first, :conditions => ['pages.name = ? AND group_participations.group_id IN (?)', name, ids], :joins => :group_participations)
  end

  
  def find_pages_by_user_and_name(user, name)
    user.pages.find(:all, :conditions => ['pages.name = ?',name])
  end
  
  def find_pages_with_unknown_context(name)
    if logged_in?
      options = options_for_me
    else
      options = options_for_public
    end
    Page.find_by_path ["name",name], options
  end
  
  def controller_for_list_of_pages(name)
    params[:action] = 'search'
    params[:path] = ['name',name]
    params[:controller] = 'pages'
    new_controller("PagesController")
  end
  
  def controller_for_page(page)
    params[:action] = params[:_page_action] || 'show'
    #params[:id] = page
    params[:controller] = page.controller
    new_controller(page.controller_class_name)
  end
  
  def controller_for_group(group)
    params[:action] = 'show'
    if group.instance_of? Network
      params[:controller] = 'network'
      new_controller('NetworkController')
    else
      params[:controller] = 'group'
      new_controller('GroupController')
    end
  end
  
  def controller_for_people
    params[:action] = 'show'
    params[:controller] = 'person'
    new_controller('PersonController')
  end
  
end
