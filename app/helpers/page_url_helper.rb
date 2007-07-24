require 'cgi'

module PageUrlHelper
   
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
    if @group and page.group_ids.include?(@group.id)
      path = page_path(@group.name, page.name_url, options)
    elsif page.group_name
      path = page_path(page.group_name, page.name_url, options)
    elsif page.created_by_id
      path = page_path(page.created_by.login, page.friendly_url, options)
    else
      path = page_path('page', page.friendly_url, options)
    end
    '/' + path + build_query_string(options)
  end
  
  def page_path(context,name,options)
    [context, name, options.delete(:action), options.delete(:id)].compact.join('/')
  end
  
  # like page_url, but it returns a direct URL that bypasses the dispatch
  # controller. intended for use with ajax calls. 
  def page_xurl(page,options={})
    hash = {:page_id => page.id, :id => 0, :action => 'show', :controller => 'tool/' + page.controller}
    direct_url(hash.merge(options))
  end
  
  # a helper for links that are destined for the PagesController, not the
  # Tool::BaseController or its decendents
  def pages_url(page,options={})
    url_for({:controller => 'pages',:id => page.id}.merge(options))
  end
  
  def create_page_link(text,options={})
    url = url_for :controller => '/pages', :action => 'create'
    ret = ""
    ret += "<form class='link' method='post' action='#{url}'>"
    options.each do |key,value|
      ret += hidden_field_tag(key,value)
    end
    ret += link_to_function(text, 'event.target.parentNode.submit()')
    ret += "</form>"
    #link_to(text, {:controller => '/pages', :action => 'create'}.merge(options), :method => :post)  
  end

  def create_page_url(page_class, options={})
    controller = "tool/" + page_class.controller 
    id = page_class.class_display_name.nameize
    "/#{controller}/create/#{id}" + build_query_string(options)
  end
  
  # 
  # returns the url that this page was 'from'.
  # used when deleting this page, and other cases where we redirect back to 
  # some higher containing context.
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
    elsif page and page.group_name
      url = ['/groups', 'show', page.group_name]
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
      
  def filter_path
    @path ||= (params[:path] || [])
  end
  def parsed_path
    return @parsed_path if @parsed_path
    @parsed_path ||= controller.parse_filter_path(filter_path)
  end

  # used to create the page list headings
  # set member variable @path beforehand if you want 
  # the links to take it into account instead of params[:path]
  def list_heading(text, action, select_by_default=false)
    path = filter_path
    parsed = parsed_path
    selected = false
    arrow = ''
    if parsed.keyword?('ascending')
      link = page_path_link(text,"descending/#{action}")
      if parsed.first_arg_for('ascending') == action
        selected = true
        arrow = image_tag('ui/sort-asc.png')
      end
    elsif parsed.keyword?('descending')
      link = page_path_link(text,"ascending/#{action}")
      if parsed.first_arg_for('descending') == action
        selected = true
        arrow = image_tag('ui/sort-desc.png')
      end
    else
      link = page_path_link(text, "ascending/#{action}")
      selected = select_by_default
      arrow = image_tag('ui/sort-desc.png') if selected
    end
    "<th nowrap class='#{selected ? 'selected' : ''}'>#{link} #{arrow}</th>"
  end

  # used to create the page list headings
  def page_path_link(text,path='',image=nil)
    hash = params.dup
    current_path = parsed_path().dup.remove_sort.to_s
    current_path += '/' if current_path.any? and !current_path.ends_with? '/'
    hash[:path] = current_path + path
    #for tags this isn't right:
    # todo: do not hard code the action here.
    if params[:controller] == 'groups' && params[:action] == 'show'
      hash[:action] = 'search'
    elsif params[:controller] == 'inbox'
      hash[:action] = 'index'
    elsif params[:controller] == 'person'
      hash[:action] = 'search'
      hash[:id] ||= hash['_context']
    end
    hash.delete('_context')
    link_to text, hash
  end

  
end
