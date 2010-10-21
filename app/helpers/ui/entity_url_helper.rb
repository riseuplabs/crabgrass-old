#
# generate urls for users and groups
# also included in ApplicationController
#

module UI::EntityUrlHelper

  protected

  ##
  ## GROUPS
  ##

  def url_for_group(arg, options={})
    name_and_url_for_group(arg,options)[1]
  end


  # if you pass options[:full_name] = true, committees will have the string
  # "group+committee" (default does not include leading "group+")
  #
  # options[:display_name] = true for groups will yield the descriptive name for display, if one exists
  #
  # This function accepts a string, a group_id (integer), or a class derived from a group
  #
  # If options[:text] = "boop %s beep", the group name will be
  # substituted in for %s, and the display name will be "boop group_name beep"
  #
  # If options[:action] is not included it is assumed to be show, and otherwise
  # the link goes to "/group/action/group_name'
  def name_and_url_for_group(arg,options={})
    if arg.instance_of? Integer
      arg = Group.find(arg)
    elsif arg.instance_of? String
      name = arg
      group = Group.find_by_name(name)
      display_name = (group ? group.display_name : name)
    elsif arg.is_a? Group
      controller = 'networks' if arg.network?
      name = arg.name
      if options[:full_name]
        display_name = arg.full_name
      elsif options[:short_name]
        display_name = arg.name
      else
        display_name = arg.display_name
      end
    end

    display_name ||= name
    display_name = options[:text] % display_name if options[:text]
    action = options[:action] || 'show'
    if options[:path]
      if options[:path].is_a? String
        path = options[:path].split('/')
      elsif options[:path].is_a? Array
        path = options[:path]
      end
      path = path.select(&:any?)
    else
      path = nil
    end

    if action == 'show'
      url = "/#{name}"
    else
      controller ||= '/groups'
      url = {:controller => controller, :action => action, :id => name}
      url[:path] = path if path
    end
    [display_name, url]
  end

  ##
  ## USERS
  ##

  # arg might be a user object, a user id, or the user's login
  def login_and_path_for_user(arg, options={})

    if arg.is_a? Integer
      # this assumes that at some point simple id based finds will be cached in memcached
      user = User.find_by_id(arg)
      login = user.try.login
      display = user.try.display_name
    elsif arg.is_a? String
      user = User.find_by_login(arg)
      login = arg
      display = user.nil? ? arg : user.display_name
    elsif arg.is_a? User
      login = arg.login
      display = arg.display_name
    end
    #link_to login, :controller => '/people', :action => 'show', :id => login if login
    action = options[:action] || 'show'
    if action == 'show'
      path = "/#{login}"
    else
      path = "/person/#{action}/#{login}"
    end
    [login, path, display]
  end

  def url_for_user(arg, options={})
    login, path, display = login_and_path_for_user(arg,options)
    path
  end


  ##
  ## GENERIC PERSON OR GROUP
  ##

  # this is a total duplication. kill it.
  def guess_url_for_entity(entity)
    case entity.class.name
    when 'Group' then url_for_group(entity)
    when 'User' then url_for_user(entity)
    end
  end

  def url_for_entity(entity, options={})
    if entity.is_a? User
      url_for_user(entity, options)
    elsif entity.is_a? Group
      url_for_group(entity, options)
    end
  end

end
