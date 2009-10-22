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
      flash.keep
      load_current_site
      find_controller.process(request, response)
    rescue ActiveRecord::RecordNotFound
      if logged_in? and (@group or (@user and @user == current_user))
        flash_message :info => '{thing} not found'[:thing_not_found, 'Page'[:page]]
        redirect_to create_page_url(WikiPage, {:group => @group, 'page[title]' => params[:_page]})
      else
        set_language do
          render(:template => 'dispatch/not_found', :status => :not_found)
        end
      end
    end
  end

  private

  def load_current_site; current_site; end

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
    elsif @user
      @page = find_page_by_user_and_name(@user, page_handle)
    else
      @pages = find_pages_with_unknown_context(page_handle)
      if @pages.size == 1
        @page = @pages.first
      elsif @pages.size > 1
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

  # Almost every page is retrieved from the database using this method.
  # (1) first, we attempt to load the page using the page owner directly.
  # (2) if that fails, then we resort to searching the entire
  #     namespace of the group
  #
  # Suppose two groups share a page. Only one can be the owner.
  #
  # When linking to the page from the owner's home, we just
  # do /owner-name/page-name. No problem, everyone is happy.
  #
  # But what link do we use for the non-owner's home? /non-owner-name/page-name.
  # This makes it so the banner will belong to the non-owner and it will not
  # be jarring click on a link from the non-owner's home and get teleported to
  # some other group.
  #
  # In order to make this work, we need the second query that includes all the
  # group participation objects.
  #
  # It is true that we could just do without the first query. It makes it slower
  # when the owner is not the context. However, this first query is much faster
  # and is likely to be used much more often than the second query.
  #
  def find_page_by_group_and_name(group, name)
    Page.find(
      :first, :conditions => [
        'pages.name = ? AND pages.owner_id = ? AND pages.owner_type = ?',
         name, group.id, 'Group'
      ]
    ) or Page.find(
      :first, :conditions => [
         'pages.name = ? AND group_participations.group_id IN (?)',
          name, Group.namespace_ids(group.id)
      ],
      :joins => :group_participations,
      :readonly => false
    )
  end

  #
  # The main method for loading pages that are in a user context.
  #
  # User context is less forgiving then group context. We only return
  # a page if the owner matches exactly.
  #
  def find_page_by_user_and_name(user, name)
    Page.find(
      :first, :conditions => [
        'pages.name = ? AND pages.owner_id = ? AND pages.owner_type = ?',
         name, user.id, 'User'
      ]
    )
  end

  def find_pages_with_unknown_context(name)
    if logged_in?
      options = options_for_me
    else
      options = options_for_public
    end
    Page.paginate_by_path ["name",name], options
  end

  def controller_for_list_of_pages(name)
    params[:action] = 'search'
    params[:path] = ['name',name]
    params[:controller] = 'pages'
    new_controller("PagesController")
  end

  def controller_for_page(page)
    if params[:_page_action] =~ /-/
      # decontruct action into controller-action
      controller, action = params[:_page_action].split('-')
      params[:action] = action
      controller = page.controller + '_' + controller
      params[:controller] = controller
      new_controller("#{controller.camelcase}Controller")
    else
      # use the main controller for this response
      params[:action] = params[:_page_action] || 'show'
      params[:controller] = page.controller
      new_controller("#{page.controller.camelcase}Controller")
    end
  end

  def controller_for_group(group)
    params[:action] = 'show'
    if group.instance_of? Network
      if current_site.network and current_site.network == group
        params[:controller] = 'site_network'
        new_controller('SiteNetworkController')
      else
        params[:controller] = 'network'
        new_controller('NetworksController')
      end
    else
      params[:controller] = 'group'
      new_controller('GroupsController')
    end
  end

  def controller_for_people
    params[:action] = 'show'
    params[:controller] = 'person'
    new_controller('PersonController')
  end

end
