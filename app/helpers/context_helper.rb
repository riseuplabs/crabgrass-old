=begin

Context
-------------------

Context is the general term for information on where we are and how we got here.
This includes breadcrumbs. Banners nowerdays are set by including the corresponding
partials from the layouts.

Sometimes the breadcrumbs are based on the context, and sometimes they are not.
Typically, breadcrumbs are based on the context for non-page controllers. For a
page controller (ie tool) the breadcrumbs are based on the breadcrumbs of the
referer (if it exists) or on the primary creator/owner of the page (otherwise).
Breadcrumbs based on the referer let us show how we got to a page, and also show
a canonical context for the page.

The breadcrumbs of the referer are stored in the session. This might result in
bloated session data, but I think that a typical user will have a pretty finite
set of referers (ie places they loaded pages from).

##################################################################################

this module is included in application.rb
=end

module ContextHelper

  protected

  ############################################################
  ## SETTING THE CONTEXT

  # before filter that may be overridden by controllers
  def breadcrumbs; end
  def context; end

  def add_context(text, url)
    @context ||= []
    if url.is_a? Hash
      url = url_for url
    end
    @context << [text,url]
  end

  ##def add_breadcrumb(text, url)
  ##  @breadcrumbs ||= []
  ##  @breadcrumbs << [text,url]
  ##end

  def set_breadcrumbs(hash)
    @breadcrumbs = hash.to_a
  end

  ############################################################
  ## CONTEXT MACROS

  # functions to do all the things necessary to set up the context
  # for a group, person, or page. these context functions are here
  # because various parts of the application might need to set a
  # group, person, or page context.

  def group_context(size='large', update_breadcrumbs=false)
    return network_context(size, update_breadcrumbs) if @group and @group.network?

    @active_tab = :groups
    add_context I18n.t(:groups), group_directory_url
    if @group and !@group.new_record?
      if @group.committee? or @group.council?
        if @group.parent
          add_context @group.parent.display_name, url_for_group(@group.parent)
        end
      end
      add_context @group.display_name, url_for_group(@group, :action => 'show')
    elsif @parent
      add_context @parent.display_name, url_for_group(@parent, :action => 'show')
    else
    end
    breadcrumbs_from_context if update_breadcrumbs
  end

  def network_context(size='large', update_breadcrumbs=true)
    @active_tab = :networks
    if @group and !@group.new_record?
      if @group == current_site.network
        site_network_context(size, update_breadcrumbs)
      else
        add_context I18n.t(:networks), network_directory_url
        add_context @group.display_name, url_for_group(@group)
      end
    else
      add_context I18n.t(:networks), network_directory_url
    end
    breadcrumbs_from_context if update_breadcrumbs
  end

  def site_network_context(size='large', update_breadcrumbs=true)
    @active_tab = :home
    add_context I18n.t(:menu_home), '/'
  end

  def person_context(size='large', update_breadcrumbs=true)
    @active_tab = :people
    add_context I18n.t(:people), people_url
    if @user
      add_context @user.display_name, url_for_user(@user, :action => 'show')
    end
    breadcrumbs_from_context if update_breadcrumbs
  end

  def me_context(size='large', update_breadcrumbs=true)
    return unless logged_in?
    @user ||= current_user
    @active_tab = :me
    add_context 'me', me_url
    breadcrumbs_from_context if update_breadcrumbs
  end

  def account_context(size='large', update_breadcrumbs=false)
    me_context(size, update_breadcrumbs)
    @active_tab = :account
  end

  def page_context
    if @page and !@page.new_record?
      if @group and @page.group_ids.include?(@group.id)
        group_context('small', false)
      elsif @page.owner_type == "Group"
        @group = @page.owner
        group_context('small', false)
      elsif @page.owner_type == "User"
        @user = @page.owner
        if current_user != @user
          person_context('small', false)
        else
          me_context('small', false)
        end
      else
        # not sure what tab should be active when there is no page owner...
        if current_site.network
          @group = current_site.network
          @active_tab = :home
        else
          @active_tab = :me
        end
      end
      if logged_in? and referer_has_crumbs?(@page)
        breadcrumbs_from_referer(@page)
      else
        breadcrumbs_from_context(false)
      end
      # add_breadcrumb( @page.title, page_url(@page, :action => 'show') )
    else
      # there is no page, but for some reason we are still using a page
      # context. so, we just use what we are given.
      if @group or @group = Group.find_by_id(params[:group_id])
        group_context('small', true)
      elsif @user and current_user != @user
        person_context('small', true)
      elsif @user and current_user == @user
        me_context('small', true)
      end
    end

  end

  def search_context
    @context = referer_crumb
    breadcrumbs_from_context(false)
  end

  def no_context
    @context = []
    @left_column = nil
    @active_tab = nil
  end

  #################################################
  ## HELPER FUNCTIONS
  ## not called anywhere except from here

  private

  def breadcrumbs_by_referer
    session[:breadcrumbs_by_referer] ||= {}
  end

  def referer_by_page_id
    session[:referer_by_page_id] ||= {}
  end

  def referer_crumb
    breadcrumbs_by_referer[referer]
  end

  def referer_or_last_crumb(page)
    breadcrumbs_by_referer[referer] ||
    breadcrumbs_by_referer[referer_by_page_id[page.id]]
  end

  def clear_referer(page)
    referer_by_page_id.delete(page.id)
  end

  # sets the breadcrumbs to be the same as the context.
  # and saves them to the session.
  def breadcrumbs_from_context(update_session=true)
    @breadcrumbs = @context
    if update_session
      breadcrumbs_by_referer[request.request_uri.sub(/\/$/,'')] = @breadcrumbs
    end
  end

  # returns array of crumbs if the referrer has breadcrumbs saved in the session
  def referer_has_crumbs?(page)
    referer_or_last_crumb(page).any?
  end

  # sets current breadcrumbs to a copy of the referer's crumbs
  # (it must be a copy so that stuff we add doesn't get saved in the session)
  def breadcrumbs_from_referer(page)
    crumb = referer_or_last_crumb(page)
    if referer_crumb
      # if a referer crumb is specifically set, update the page id crumb.
      referer_by_page_id[page.id] = referer
    end
    @breadcrumbs = crumb.dup
  end

  # returns the URL that is the last enclosing element of the context.
  def url_for_page_context(page)
    refcrumbs = referer_or_last_crumb(page)
    return (refcrumbs.last.last if refcrumbs.any?)
  end

end
