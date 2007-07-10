#################################################################################
# Context
#
# Context is the general term for information on where we are and how we got here.
# This includes breadcrumbs and banner, although each work differently. 
#
# The banner is based on the context. For example, the context might be 'groups > 
# rainbow > my nice page'. 
#
# Sometimes the breadcrumbs are based on the context, and sometimes they are not. 
# Typically, breadcrumbs are based on the context for non-page controllers. For a 
# page controller (ie tool) the breadcrumbs are based on the breadcrumbs of the 
# referer (if it exists) or on the primary creator/owner of the page (otherwise). 
# Breadcrumbs based on the referer let us show how we got to a page, and also show
# a canonical context for the page (via the banner). 
#
# The breadcrumbs of the referer are stored in the session. This might result in 
# bloated session data, but I think that a typical user will have a pretty finite 
# set of referers (ie places they loaded pages from). 
#
##################################################################################

# this module is included in application.rb

module ContextHelper

  protected

  ############################################################
  ## SETTING THE CONTEXT
  
  # before filter that may be overridden by controllers
  def breadcrumbs; end
  def context; end
    
  def add_context(text, url)
    @context ||= []
    @context << [text,url]
  end

  def add_breadcrumb(text, url)
    @breadcrumbs ||= []
    @breadcrumbs << [text,url]
  end
  
  def set_banner(partial, style)
    @banner_partial = partial
    @banner_style = style
  end

  ############################################################
  ## CONTEXT MACROS
  
  # functions to do all the things necessary to set up the context
  # for a group, person, or page. these context functions are here
  # because various parts of the application might need to set a
  # group, person, or page context. 

  def group_context(size='large', update_breadcrumbs=true)
    add_context 'groups', groups_url(:action => 'list')
    if @group
      if @group.instance_of? Committee
        add_context @group.parent.short_name, groups_url(:id => @group.parent, :action => 'show')
      end
      add_context @group.short_name, url_for_group(@group, :action => 'show')
      set_banner "groups/banner_#{size}", @group.banner_style
    end
    breadcrumbs_from_context if update_breadcrumbs
  end
  
  def person_context(size='large', update_breadcrumbs=true)
    add_context 'people', people_url
    if @user
      add_context @user.login, people_url(:action => 'show', :id => @user)
      set_banner "people/banner_#{size}", @user.banner_style
    end
    breadcrumbs_from_context if update_breadcrumbs
  end

  def me_context(size='large', update_breadcrumbs=true)
    @user ||= current_user
    add_context 'me', me_url
    set_banner 'me/banner', current_user.banner_style
    breadcrumbs_from_context if update_breadcrumbs
  end

  def page_context
    if @page
      # the context rules when there is a @page are copied from page_url_helper.rb
      # see comments on page_url for the details.
      if @group and @page.group_ids.include?(@group.id)
        group_context('small', false)
      elsif @page.group_name
        @group = @page.group
        group_context('small', false)
      elsif @page.created_by_id
        @user = @page.created_by
        if current_user != @user
          person_context('small', false)
        else
          me_context('small', false)
        end
      else
        # unknown context. will we ever get here?
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
        group_context('small', false)
      elsif @user and current_user != @user
        person_context('small', false)
      elsif @user and current_user == @user
        me_context('small', false)
      end
    end

  end


  #################################################
  ## HELPER FUNCTIONS

  def referer
    @referer ||= get_referer
  end
    
  def get_referer
    return false unless raw = request.env["HTTP_REFERER"]
    server = request.env["SERVER_NAME"]
    prot = request.protocol
    if raw.starts_with?("#{prot}#{server}/")
      raw.sub(/^#{prot}#{server}/, '')
    else
      false
    end
  end

  def breadcrumbs_by_referer
    session[:breadcrumbs_by_referer] ||= {}
  end
  
  def referer_by_page_id
    session[:referer_by_page_id] ||= {}
  end

  def referer_crumb
    session[:breadcrumbs_by_referer][referer]
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
      breadcrumbs_by_referer[request.request_uri] = @breadcrumbs
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

