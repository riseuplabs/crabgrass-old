#
# For handling links and urls to pages
#

module Page::UrlHelper

  protected

  #
  # build a url of the form:
  #
  #    /:context/:page/:action/:id
  #
  # what is the :context? the order of precedence:
  #   1. current group name if set in the url and it has access to the page
  #   2. name of the page's primary group if it exists
  #   3. the user login that created the page
  #   4. 'page'
  #
  # what is :page? it will be the page name if it exists and the context
  # is a group. Otherwise, :page will have a friendly url that starts
  # with the page id.
  #
  def page_url(page,options={})
    options.delete(:action) if options[:action] == 'show' and not options[:id]
    if @group and @group.is_a?(Group) and page.group_ids.include?(@group.id)
      path = page_path(@group.name, page.name_url, options)
    elsif page.owner_name
      path = page_path(page.owner_name, page.name_url, options)
    elsif page.created_by_id
      path = page_path(page.created_by_login, page.friendly_url, options)
    else
      path = page_path('page', page.friendly_url, options)
    end
    '/' + path + build_query_string(options)
  end

  def page_path(context,name,options)
    # if controller is set, encode it with the action.
    action = [options.delete(:controller), options.delete(:action)].compact.join('-')
    [context, name, action, options.delete(:id).to_s].select(&:any?).join('/')
  end

  # like page_url, but it returns a direct URL that bypasses the dispatch
  # controller. intended for use with ajax calls.
  def page_xurl(page,options={})
    options[:controller] = '/' + [page.controller, options.delete(:controller)].compact.join('_')
    hash = {:page_id => page.id, :id => 0, :action => 'show'}
    url_for(hash.merge(options))
  end

  # a helper for links that are destined for the PagesController, not the
  # BasePageController or its decendents
  def pages_url(page,options={})
    url_for({:controller => 'pages',:id => page.id}.merge(options))
  end

  #
  # returns the url that this page was 'from'.
  # used when deleting this page, and other cases where we redirect back to
  # some higher containing context.
  #
  # TODO: i think this is no longer needed and should be phased out.
  #
  def from_url(page=nil)
    if page and (url = url_for_page_context(page))
      return url
    elsif @group
      url = ['/groups', 'show', @group]
    elsif @user == current_user
      url = ['/me',     nil,    nil]
    elsif @user
      url = ['/people', 'show', @user]
    elsif logged_in?
      url = ['/me',     nil,    nil]
    elsif page and page.owner_name
      return '/'+page.owner_name
    else
      raise "From url cannot be determined" # i don't know what to do here.
    end
    url_for :controller => url[0], :action => url[1], :id => url[2]
  end

  #
  # lifted from active_record's routing.rb
  #
  # Build a query string from the keys of the given hash. If +only_keys+
  # is given (as an array), only the keys indicated will be used to build
  # the query string. The query string will correctly build array parameter
  # values.
  def build_query_string(hash, only_keys=nil)
    elements = []

    only_keys ||= hash.keys

    only_keys.each do |key|
      value = hash[key] or next
      key = CGI.escape key.to_s
      if value.class == Array
        key <<  '[]'
      else
        value = [ value ]
      end
      value.each { |val| elements << "#{key}=#{CGI.escape(val.to_param.to_s)}" }
    end

    query_string = "?#{elements.join("&")}" unless elements.empty?
    query_string || ""
  end

end

