#
# generate links and display of users and groups
#

module UI::EntityDisplayHelper

  protected

  ##
  ## GROUPS
  ##

  # see function name_and_path_for_group for description of options
  def link_to_group(arg, options={})
    if arg.is_a? Integer
      @group_cache ||= {}
      # hacky fix for error when a page persists after it's group is deleted --af
      # what is this trying to do? --e
      if not @group_cache[arg]
        if Group.exists?(arg)
          @group_cache[arg] = Group.find(arg)
        else
          return ""
        end
      end
      # end hacky fix
      arg = @group_cache[arg]
    end

    display_name, path = name_and_url_for_group(arg,options)
    style = options[:style] || ""
    label = options[:label] || display_name
    klass = options[:class] || 'name_icon'
    avatar = ''
    if options[:avatar_as_separate_link] # not used for now
      avatar = link_to(avatar_for(arg, options[:avatar], options), :style => style)
    elsif options[:avatar]
      klass += " #{options[:avatar]}"
      url = avatar_url_for(arg, options[:avatar])
      style = "background-image:url(#{url});" + style
    end
    avatar + link_to(label, path, :class => klass, :style => style)
  end

  # see function name_and_path_for_group for description of options
  def link_to_group_avatar(arg, options={})
    if arg.is_a? Integer
      @group_cache ||= {}
      # hacky fix for error when a page persists after it's group is deleted --af
      # what is this trying to do? --e
      if not @group_cache[arg]
        if Group.exists?(arg)
          @group_cache[arg] = Group.find(arg)
        else
          return ""
        end
      end
      # end hacky fix
      arg = @group_cache[arg]
    end

    display_name, path = name_and_url_for_group(arg,options)
    style = options[:style] || ""
    label = options[:label] || display_name
    klass = options[:class] || 'name_icon'
    options[:title] ||= display_name
    options[:alt] ||= display_name
    link_to(avatar_for(arg, options[:avatar], options), path, :class => klass,  :style => style)
  end


  ##
  ## USERS
  ##

  # creates a link to a user, with or without the avatar.
  # avatars are displayed as background images, with padding
  # set on the <a> tag to make room for the image.
  # accepts:
  #  :avatar => [:small | :medium | :large]
  #  :label -- override display_name as the link text
  #  :style -- override the default style
  #  :class -- override the default class of the link (name_icon)
  def link_to_user(arg, options={})
    login, path, display_name = login_and_path_for_user(arg,options)
    return "" if login.blank?

    style = options[:style] || ""                   # allow style override
    label = options[:login] ? login : display_name  # use display_name for label by default
    label = options[:label] || label                # allow label override
    if label.length > 19
      options[:title] = label
      label = truncate(label, :length => 19)
    end
    options[:title] ||= ""
    klass = options[:class] || 'name_icon'
    style += " display:block" if options[:block]
    avatar = ''
    if options[:avatar_as_separate_link] # not used for now
      avatar = link_to(avatar_for(arg, options[:avatar], options), :style => style, :title => label)
    elsif options[:avatar]
      klass += " #{options[:avatar]}"
      url = avatar_url_for(arg, options[:avatar])
      style = "background-image:url(#{url});" + style
    end
    avatar + link_to(label, path, :class => klass, :style => style, :title => options[:title])
  end

  # creates a link to a user, with or without the avatar.
  # avatars are displayed as background images, with padding
  # set on the <a> tag to make room for the image.
  # accepts:
  #  :avatar => [:small | :medium | :large]
  #  :label -- override display_name as the link text
  #  :style -- override the default style
  #  :class -- override the default class of the link (name_icon)
  def link_to_user_avatar(arg, options={})
    login, path, display_name = login_and_path_for_user(arg,options)
    return "" if login.blank?

    style = options[:style] || ""                   # allow style override
    label = options[:login] ? login : display_name  # use display_name for label by default
    label = options[:label] || label                # allow label override
    klass = options[:class] || 'name_icon'
    options[:title] ||= display_name
    options[:alt] ||= display_name

    avatar = link_to(avatar_for(arg, options[:avatar], options), path,:class => klass, :style => style)
  end

  ##
  ## GENERIC PERSON OR GROUP
  ##

  def link_to_entity(entity, options={})
    if entity.is_a? User
      link_to_user(entity, options)
    elsif entity.is_a? Group
      link_to_group(entity, options)
    end
  end

  # Display a group or user, without a link. All such displays should be made by
  # this method.
  #
  # options:
  #   :avatar => nil | :xsmall | :small | :medium | :large | :xlarge (default: nil)
  #   :format => :short | :full | :both | :hover | :twolines (default: full)
  #   :block => false | true (default: false) DEPRECATED, use :tag instead.
  #   :link => nil | true | url (default: nil)
  #   :class => passed through to the tag as html class attr
  #   :style => passed through to the tag as html style attr
  #   :tag   => the html tag to use for this display (ie :div, :span, :li, :a, etc)
  #
  def display_entity(entity, options={})
    options = {:format => :full}.merge(options)
    display = nil; hover = nil
    options[:class] = [options[:class], 'entity'].join(' ')
    options[:block] = true if options[:format] == :twolines
    options[:link] = true if options[:tag] == :a

    name = entity.name
    display_name = h(entity.display_name)
    both_names = h(entity.both_names)
    if options[:link]
      url = options[:link] === true ? url_for_entity(entity) : options[:link]
      if options[:tag] == :a
        href = url
      else
        name         = link_to(name, url)
        display_name = link_to(display_name, url)
        both_name    = link_to(both_names, url)
        href = nil
      end
    end

    if options[:avatar]
      url = avatar_url_for(entity, options[:avatar])
      options[:class] = [options[:class], "name_icon", options[:avatar]].compact.join(' ')
      options[:style] = [options[:style], "background-image:url(#{url})"].compact.join(';')
    end
    display, title, hover = case options[:format]
      when :short then [name,         display_name, nil]
      when :full  then [display_name, name,         nil]
      when :both  then [both_names,   nil,          nil]
      when :hover then [name,         nil,          display_name]
      when :twolines then ["<div class='name'>%s</div>%s"%[name, (display_name if name != display_name)], nil, nil]
    end
    if hover
      display += content_tag(:b,hover)
      options[:style] = [options[:style], "position:relative"].compact.join(';')
      # ^^ to allow absolute popup with respect to the name
    end
    if options[:format] == :twolines and name != display_name
      options[:class] = [options[:class], 'two'].combine
    end
    element = options[:tag] || (options[:block] ? :div : :span)
    content_tag(element, display, :style => options[:style], :class => options[:class], :title => title, :href => href)
  end

end
