require 'cgi'

=begin

These are page related helpers that might be needed anywhere in the code.
For helpers just for page controllers, see base_page_helper.rb

=end

module PageHelper
  
  ######################################################
  ## PAGE URLS

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
    elsif page.group_name
      path = page_path(page.group_name, page.name_url, options)
    elsif page.created_by_id
      path = page_path(page.created_by_login, page.friendly_url, options)
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
    hash = {:page_id => page.id, :id => 0, :action => 'show', :controller => '/' + page.controller}
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
      
  def filter_path(path=nil)
    @path ||= (path || params[:path] || [])
  end
  def parsed_path(path=nil)
    @parsed_path ||= controller.parse_filter_path(path || filter_path)
  end


  ######################################################
  ## PAGE LISTINGS AND TABLES

  # Used to create the page list headings. set member variable @path beforehand
  # if you want the links to take it into account instead of params[:path]
  def list_heading(text, action, select_by_default=false)
    return "<th nowrap>#{text}</th>" unless 
      %(created_at created_by_login updated_at updated_by_login group_name title starts_at posts_count).include? action 

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

  ## used to create the page list headings
  ## this will create very odd results if *path is not in the current route.
  def page_path_link(text,path='',image=nil)
    hash = params.dup
    new_path = controller.parse_filter_path(path)
    current_path = controller.parse_filter_path(hash[:path])
    hash[:path] = current_path.merge(new_path).flatten

    link_to text, hash
  end

  #
  # used to spit out a column value for a single row.
  # for example:
  #  page_column(page, :title)
  # this function exists so we can re-arrange the columns easily.
  #
  def page_list_cell(page, column, participation=nil)
    if column == :icon
      page_icon(page)
    elsif column == :checkbox
      check_box('page_checked', page.id, {:class => 'page_check'}, 'checked', '')
    elsif column == :title
      page_list_title(page, column, participation)
    elsif column == :updated_by or column == :updated_by_login
      page.updated_by_login ? link_to_user(page.updated_by_login) : '&nbsp;'
    elsif column == :created_by or column == :created_by_login
      page.created_by_login ? link_to_user(page.created_by_login) : '&nbsp;'
    elsif column == :updated_at
      friendly_date(page.updated_at)
    elsif column == :created_at
      friendly_date(page.created_at)
    elsif column == :happens_at
      friendly_date(page.happens_at)
    elsif column == :group or column == :group_name
      page.group_name ? link_to_group(page.group_name) : '&nbsp;'
    elsif column == :contributors_count or column == :contributors
      page.contributors_count
    elsif column == :owner
      page.group_name || page.created_by_login
    elsif column == :owner_with_icon
      page_list_owner_with_icon(page)
    elsif column == :posts
      page.posts_count
    elsif column == :last_post
      if page.discussion
        content_tag :span, "%s &bull; %s &bull; %s" % [friendly_date(page.discussion.replied_at), link_to_user(page.discussion.replied_by), link_to('view'[:view], page_url(page)+"#posts-#{page.discussion.last_post_id}")]
      end
    else
      page.send(column)
    end
  end

  def page_list_owner_with_icon(page)
    if page.group_id
      return link_to_group(page.group_id, :avatar => 'xsmall')
    elsif page.created_by
      return link_to_user(page.created_by, :avatar => 'xsmall')
    end
  end
  
  def page_list_updated_or_created(page)
    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
    label    = field == 'updated_at' ? 'updated'.t : 'created'.t
    username = link_to_user(page.updated_by_login)
    date     = friendly_date(page.send(field))
    content_tag :span, "%s &bull; %s &bull; %s" % [label, username, date]
  end

  def page_list_title(page, column, participation = nil)
    title = link_to(page.title, page_url(page))
    if participation and participation.instance_of? UserParticipation
      title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless participation.resolved?
      title += " " + image_tag("emblems/star.png", :size => "11x11", :title => 'star') if participation.star?
    else
      title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless page.resolved?
    end
    if page.flag[:new]
      title += " <span class='newpage'>#{'new'.t}</span>"
    end
    return title
  end
  
  def page_list_heading(column=nil)
    if column == :group or column == :group_name
      list_heading 'group'.t, 'group_name'
    elsif column == :icon or column == :checkbox or column == :discuss
      "<th></th>"
    elsif column == :updated_by or column == :updated_by_login
      list_heading 'updated by'[:page_list_heading_updated_by], 'updated_by_login'
    elsif column == :created_by or column == :created_by_login
      list_heading 'created by'[:page_list_heading_created_by], 'created_by_login'
    elsif column == :updated_at
      list_heading 'updated'[:page_list_heading_updated], 'updated_at'
    elsif column == :created_at
      list_heading 'created'[:page_list_heading_updated_by], 'created_at'
    elsif column == :posts
      list_heading 'posts'[:page_list_heading_posts], 'posts_count'
    elsif column == :happens_at
      list_heading 'happens'.t, 'happens_at'
    elsif column == :contributors_count or column == :contributors
      list_heading image_tag('ui/person-dark.png'), 'contributors_count'
    elsif column == :last_post
      list_heading 'last post'[:page_list_heading_last_post], 'updated_at'
    elsif column
      list_heading column.to_s.t, column.to_s
    end    
  end

  ######################################################
  ## PAGE MANIPULATION

  #
  # Often when you run a page search, you will get an array of UserParticipation
  # or GroupParticipation objects. 
  #
  # This method will convert the array to Pages if they are not.
  #
  def array_of_pages(pages)
    if pages
      if pages.first.is_a? Page
        return pages
      else
        return pages.collect{|p|p.page}
      end
    end
  end

  ######################################################
  ## FORM HELPERS

  ## options for a page type dropdown menu
  def options_for_select_page_type(default_selected)
    array = @site.available_page_types.collect do |page_class_string|
      page_class = Page.class_name_to_class(page_class_string)
      page_group = page_class.class_group.first
      [page_group.pluralize, page_group]
    end
    options_for_select([['all page types'.t,'']] + array, default_selected)
  end
  
  ## Creates options useable in a select() for the various states
  ## a page might be in. Used to filter on these states
  def options_for_page_states(parsed_path)
    selected = ''
    selected = 'pending' if parsed_path.keyword?('pending')
    selected = 'unread' if parsed_path.keyword?('unread')
    selected = 'starred' if parsed_path.keyword?('starred')
    selected = parsed_path.first_arg_for('page_state') if parsed_path.keyword?('page_state')
    options_for_select(['unread','pending','starred'].to_localized_select, selected)
  end

  ## Link to the action for the form to create a page of a particular type.
  def create_page_url(page_class=nil, options={})
    if page_class
      controller = page_class.controller 
      id = page_class.class_display_name.nameize
      "/#{controller}/create/#{id}" + build_query_string(options)
    else
      url_for(:controller => '/pages', :action => 'create')
    end
  end

#  def create_page_link(text,options={})
#    url = url_for :controller => '/pages', :action => 'create'
#    ret = ""
#    ret += "<form class='link' method='post' action='#{url}'>"
#    options.each do |key,value|
#      ret += hidden_field_tag(key,value)
#    end
#    ret += link_to_function(text, 'event.target.parentNode.submit()')
#    ret += "</form>"
#    #link_to(text, {:controller => '/pages', :action => 'create'}.merge(options), :method => :post)  
#  end
  
end
