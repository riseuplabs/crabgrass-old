require 'cgi'

module PageUrlHelper
   
  #
  # build a url of the form:
  #  
  #    /:context/:page/:action/:id
  #
  # what is the :context? the order of precedence: 
  #   1. current group name
  #   2. current user name
  #   3. page's primary group name
  #   4. 'page'
  #
  # what is :page? it will be the page name if it exists and the context
  # is a group. Otherwise, :page will have a friendly url that starts
  # with the page id.
  # 
  def page_url(page,options={})
    options.delete(:action) if options[:action] == 'show' and not options[:id]
    if @group and page.group_ids.include?(@group.id)
      path = page_path(@group.name,     page.name_url,     options)
    elsif @user
      path = page_path(@user.login,     page.friendly_url, options)
    elsif page.group_name
      path = page_path(page.group_name, page.name_url,     options)
    else
      path = page_path('page',          page.friendly_url, options)
    end
    '/' + path + build_query_string(options)
  end
  
  def page_path(context,name,options)
    [context, name, options.delete(:action), options.delete(:id)].compact.join('/')
  end
  
  # 
  # returns the url that this page was 'from'.
  # used when deleting this page, and other cases where we redirect back to 
  # some higher containing context.
  # 
  def from_url(page=nil)
    ary = if @group
      ['/groups', 'show', @group]
    elsif @user
      ['/people', 'show', @user]
    elsif logged_in?
      ['/me',     nil,    nil]
    elsif page and page.group_name
      ['/groups', 'show', page.group_name]
    else
      raise "From url cannot be determined" # i don't know what to do here.
    end
    url_for :controller => ary[0], :action => ary[1], :id => ary[2]
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
