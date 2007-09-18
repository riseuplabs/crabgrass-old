module UrlHelper

  def name_and_path_for_group(arg,options={})
    if arg.instance_of? Integer
      # this assumes that at some point simple id based finds will be cached in memcached
      name = Group.find(arg).name
    elsif arg.instance_of? String
      name = arg
    elsif arg.is_a? Committee
      name = arg.name
      display_name = arg.display_name
    elsif arg.is_a? Group
      name = arg.name
    end
    display_name ||= name
    display_name = options[:text] % display_name if options[:text]
    action = options[:action] || 'show'
    if action == 'show'
      path = "/#{name}"
    else
      path = "/groups/#{action}/#{name}"
    end
    [display_name, path]  
  end

  def url_for_group(arg, options={})
    display_name, path = name_and_path_for_group(arg,options)
    path
  end

  # arg might be a user object, a user id, or the user's login
  def login_and_path_for_user(arg, options={})
    if arg.is_a? Integer
      # this assumes that at some point simple id based finds will be cached in memcached
      login = User.find(arg).login 
    elsif arg.is_a? String
      login = arg
    elsif arg.is_a? User
      login = arg.login
    end
    #link_to login, :controller => '/people', :action => 'show', :id => login if login
    action = options[:action] || 'show'
    if action == 'show'
      path = "/#{login}"
    else
      path = "/person/#{action}/#{login}"
    end
    [login, path]
  end
  
  def url_for_user(arg, options={})
    login, path = login_and_path_for_user(arg,options)
    path
  end
  
  def link_to_user(arg, options={})
    login, path = login_and_path_for_user(arg,options)
    style = options[:style] || ''
    if options[:avatar]
      size = Avatar.pixels(options[:avatar])[0..1].to_i
      padding = size/5 + size
      url = avatar_url(:id => (arg.avatar||0), :size => options[:avatar])
      style = "background: url(#{url}) no-repeat 0% 50%; padding-left: #{padding}px; " + style
    end
    link_to login, path, :class => 'name_link', :style => style
  end
  
  def link_to_group(arg, options={})
    display_name, path = name_and_path_for_group(arg,options)
    style = options[:style] || ''
    if options[:avatar]
      size = Avatar.pixels(options[:avatar])[0..1].to_i
      padding = size/5 + size
      url = avatar_url(:id => (arg.avatar||0), :size => options[:avatar])
      style = "background: url(#{url}) no-repeat 0% 50%; padding-left: #{padding}px;" + style
    end
    link_to display_name, path, :class => 'name_link', :style => style
  end

  def url_for_entity(entity, options={})
    if entity.is_a? User
      url_for_user(entity, options)
    elsif entity.is_a? Group
      url_for_group(entity, options)
    end
  end

end
