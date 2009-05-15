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
    elsif page.owner_name
      path = page_path(page.owner_name, page.name_url, options)
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
    # if controller is set, encode it with the action.
    action = [options.delete(:controller), options.delete(:action)].compact.join('-')
    [context, name, action, options.delete(:id)].select{|x|
      (x.respond_to?(:any?) && x.any?) || true }.join('/')
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
  
  def filter_path()
    params[:path] || []
  end
  def parsed_path(path=nil)
    if path
      @latest_parsed_path = controller.parse_filter_path(path)
    else
      @latest_parsed_path ||= controller.parse_filter_path(filter_path)
    end
    return @latest_parsed_path
  end


  ######################################################
  ## PAGE LISTINGS AND TABLES

  SORTABLE_COLUMNS = %w(
    created_at created_by_login updated_at updated_by_login group_name owner_name 
    title starts_at posts_count contributors_count stars
  ).freeze

  # Used to create the page list headings. set member variable @path beforehand
  # if you want the links to take it into account instead of params[:path]
  # option defaults:
  #  :selected => false
  #  :sortable => true
  def list_heading(text, action, options={})
    options = {:selected => false, :sortable => true}.merge(options)

    unless options[:sortable] and SORTABLE_COLUMNS.include?(action)
      return content_tag(:th, text, :class => options[:class])
    end

    path   = filter_path()
    parsed = parsed_path()
    selected = false
    arrow = ''
    if parsed.sort_arg?(action)
      selected = true
      if parsed.keyword?('ascending')
        link = page_path_link(text,"descending/#{action}")
        arrow = icon_tag('sort_up')
      else
        link = page_path_link(text,"ascending/#{action}")
        arrow = icon_tag('sort_down')
      end
    elsif %w(title created_by_login updated_by_login group_name).include? action
      link = page_path_link(text, "ascending/#{action}")
      selected = options[:selected]
    else
      link = page_path_link(text, "descending/#{action}")
      selected = options[:selected]
    end
    content_tag :th, "#{link} #{arrow}", :class => "#{selected ? 'selected' : ''} #{options[:class]} nowrap"
  end

  ## used to create the page list headings

  def page_path_link(text,path='',image=nil)

    hash         = params.dup
    new_path     = parsed_path(path)
    current_path = parsed_path(hash[:path])
    hash[:path]  = current_path.merge(new_path).flatten

    if params[:_context]
      # special hack for landing pages using the weird dispatcher route.
      hash = "/%s?path=%s" % [params[:_context], hash[:path].join('/')]
    end

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
    elsif column == :stars_count or column == :stars
      if page.stars > 0
        content_tag(:span, "%s %s" % [icon_tag('star'), page.stars], :class => 'star')
      else
        icon_tag('star_empty')
      end
    elsif column == :owner
      page.owner_name
    elsif column == :owner_with_icon
      page_list_owner_with_icon(page)
    elsif column == :last_updated
      page_list_updated_or_created(page)
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
    return unless page.owner
    if page.owner_type == "Group"
      return link_to_group(page.owner, :avatar => 'xsmall')
    else
      return link_to_user(page.owner, :avatar => 'xsmall')
    end
  end
  
  def page_list_updated_or_created(page)
    field    = (page.updated_at > page.created_at + 1.hour) ? 'updated_at' : 'created_at'
    label    = field == 'updated_at' ? content_tag(:span, 'updated'.t) : content_tag(:span, 'new'.t, :class=>'new')
    username = link_to_user(page.updated_by_login)
    date     = friendly_date(page.send(field))
    content_tag :span, "%s <br/> %s &bull; %s" % [username, label, date], :class => 'nowrap'
  end

  def page_list_title(page, column, participation = nil)
    title = link_to(h(page.title), page_url(page))
    if participation and participation.instance_of? UserParticipation
      title += " " + icon_tag("tiny_pending") unless participation.resolved?
      title += " " + icon_tag("tiny_star") if participation.star?
    else
      title += " " + icon_tag("tiny_pending") unless page.resolved?
    end
    if page.flag[:new]
      title += " <span class='newpage'>#{'new'.t}</span>"
    end
    return title
  end
  
  def page_list_heading(column, options={})
    if column == :group or column == :group_name
      list_heading 'group'.t, 'group_name', options
    
    # empty <th>s contain an nbsp to prevent collapsing in IE
    elsif column == :icon or column == :checkbox or column == :discuss
      "<th>&nbsp;</th>" 
    
    elsif column == :updated_by or column == :updated_by_login
      list_heading 'updated by'[:page_list_heading_updated_by], 'updated_by_login', options
    elsif column == :created_by or column == :created_by_login
      list_heading 'created by'[:page_list_heading_created_by], 'created_by_login', options
    elsif column == :updated_at
      list_heading 'updated'[:page_list_heading_updated], 'updated_at', options
    elsif column == :created_at
      list_heading 'created'[:page_list_heading_created], 'created_at', options
    elsif column == :posts
      list_heading 'posts'[:page_list_heading_posts], 'posts_count', options
    elsif column == :happens_at
      list_heading 'happens'.t, 'happens_at', options
    elsif column == :contributors_count or column == :contributors
      list_heading image_tag('ui/person-dark.png'), 'contributors_count', options
    elsif column == :last_post
      list_heading 'last post'[:page_list_heading_last_post], 'updated_at', options
    elsif column == :stars or column == :stars_count
      list_heading 'stars'[:page_list_heading_stars], 'stars', options
    elsif column == :owner_with_icon || column == :owner
      list_heading "owner"[:page_list_heading_owner], 'owner_name', options
    elsif column == :last_updated
      list_heading "last updated"[:page_list_heading_last_updated], 'updated_at', options
    elsif column
      list_heading column.to_s.t, column.to_s, options
    end
  end

  def page_row(page, columns, participation=nil)
    participation ||= page.flag[:user_participation]
    unread = (participation && !participation.viewed?)
    participation ||= page.flag[:group_participation]

    trs = []
    tds = []
    tds << content_tag(:td, page_list_cell(page,columns[0], participation), :class=>'first')
    columns[1..-2].each do |column|
      tds << content_tag(:td, page_list_cell(page,column, participation))
    end
    tds << content_tag(:td, page_list_cell(page,columns[-1], participation), :class=>'last')
    trs << content_tag(:tr, tds.join("\n"), (unread ? {:class =>  'unread'}:{}))

    if participation and participation.is_a? UserParticipation and participation.notice
      participation.notice.each do |notice| 
        next unless notice.is_a? Hash
        trs << page_notice_row(notice, columns.size)
      end
    end

    if page.flag[:excerpt]
      trs << content_tag(:tr, content_tag(:td, page.flag[:excerpt], :class => 'excerpt', :colspan=>columns.size))
    end
    trs.join("\n")
  end

  def page_notice_row(notice, column_size)
    html = "<td class='excerpt', colspan='#{column_size}'>"
    html += "page sent by {user} on {date}"[:page_notice_message, {:user => link_to_user(notice[:user_login]), :date => friendly_date(notice[:time])}]
    if notice[:message].any?
      html += ' '+'with message'.t + " &ldquo;<i>%s</i>&rdquo;" % h(notice[:message])
    end
    html += "</td>"
    content_tag(:tr, html, :class => "page_info")
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

  #
  # Sometimes we want to divide a list of time ordered +pages+
  # into several collections by recency.
  #
  def divide_pages_by_recency(pages)
    today = []; yesterday = []; week = []; later = [];
    pages = array_of_pages(pages).dup
    page = pages.shift
    while page and after_day_start?(page.updated_at)
      today << page
      page = pages.shift
    end
    while page and after_yesterday_start?(page.updated_at)
      yesterday << page
      page = pages.shift
    end
    while page and after_week_start?(page.updated_at)
      week << page
      page = pages.shift
    end
    # unless today.size + yesterday.size + week.size > 0
    #   show_time_dividers = false
    # else
    while page
      later << page
      page = pages.shift
    end
    # end

    return today, yesterday, week, later
  end

  ######################################################
  ## FORM HELPERS

  def display_page_class_grouping(group)
    "page_group_#{group.gsub(':','_')}".t 
  end
  
  def tree_of_page_types(available_page_types=nil)
    available_page_types ||= current_site.available_page_types
    page_groupings = []
    available_page_types.each do |page_class_string|
      page_class = Page.class_name_to_class(page_class_string)
      page_groupings.concat page_class.class_group
    end
    page_groupings.uniq!
    tree = [] 
    page_groupings.each do |grouping|
      entry = {:name => grouping, :display => display_page_class_grouping(grouping),
         :url => grouping.gsub(':','-')}
      entry[:pages] = Page.class_group_to_class(grouping).collect
      tree << entry
    end
    tree.sort!{|a,b| a[:display] <=> b[:display] }
    return tree
  end
  
  ## options for a page type dropdown menu for searching
  def options_for_select_page_type(default_selected=nil)
    default_selected.sub!(' ', '+') if default_selected
    menu_items = []
    tree_of_page_types.each do |grouping|
      menu_items << [grouping[:display], grouping[:url]]
      sub_items = grouping[:pages].collect do |page_class|
         ["#{grouping[:display]} > #{page_class.class_display_name}",
         "#{grouping[:url]}+#{page_class.url}"]
       end
       menu_items.concat sub_items if sub_items.size > 1
    end
    options_for_select([['all page types'.t,'']] + menu_items, default_selected)
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
      url_for(options.merge(:controller => '/pages', :action => 'create'))
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
