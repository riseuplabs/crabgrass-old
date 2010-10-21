#
# Here lies many helpers for making links
#

module UI::LinkHelper

  # link to if and only if...
  # like link_to_if, but return nil if the condition is false
  # not widely used. candidate for purging.
  def link_to_iff(condition, name, options = {}, html_options = {}, &block)
    if condition
      link_to(name, options, html_options, &block)
    else
      nil
    end
  end

  ##
  ## FORMS
  ##

  def submit_link(label, options={})
    name = options.delete(:name) || 'commit'
    value = options.delete(:value) || label
    accesskey = shortcut_key label
    onclick = %Q<submitForm(this, "#{name}", "#{value}");>
    if options[:confirm]
      onclick = %Q<if(confirm("#{options[:confirm]}")){#{onclick};}else{return
 false;}>
    end
    %Q(<span class='#{options[:class]}'><a href='#' onclick='#{onclick}' style
='#{options[:style]}' class='#{options[:class]}' accesskey='#{accesskey}'>#{
label}</a></span>)
  end

  ##
  ## UTILITY
  ##

  ## makes this: link | link | link
  def link_line(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:div, links.compact.join(char), :class => 'link_line')
  end

  def link_span(*links)
    char = content_tag(:em, link_char(links))
    content_tag(:span, links.compact.join(char), :class => 'link_line')
  end

  ##
  ## ACTIVE LINKS
  ##

  # just like link_to, but sets the <a> tag to have class 'active'
  # if last argument is true or if the url is in the form of a hash
  # and the current params match this hash.
  # TODO: the signature of this helper should be changed to match that
  # of link_to_remote_active.
  def link_to_active(link_label, url_hash, active=nil, html_options={})
    active = active || url_active?(url_hash)
    selected_class = active ? 'active' : ''
    html_options[:class] = [html_options[:class], selected_class].combine
    link_to(link_label, url_hash, html_options)
  end

  # like link_to_remote, but sets the class to be 'active' if the link is
  # active (:active => true)
  def link_to_remote_active(link_label, options, html_options={})
    active = options.delete(:active) || html_options.delete(:active)
    selected_class = active ? 'active' : ''
    html_options[:class] = [html_options[:class], selected_class].combine
    if options[:icon] or html_options[:icon]
      link_to_remote_with_icon(link_label, options, html_options)
    else
      link_to_remote(link_label, options, html_options)
    end
  end

  ##
  ## LINKS WITH ICONS
  ##

  # makes a cool link with an icon. if you click the link, some ajax
  # thing happens, and the icon is set to a spinner. The icon is
  # restored when the ajax request completes.
  def link_to_remote_with_icon(label, options, html_options={})
    icon = options.delete(:icon) || html_options.delete(:icon)
    id = html_options[:id] || 'link%s'%rand(1000000)
    if options[:confirm]
      icon_options = {} # don't bother with spinner for confirm links
    else
      icon_options = {
        :loading => [spinner_icon_on(icon, id), options[:loading]].combine(';'),
        :complete => [spinner_icon_off(icon, id), options[:complete]].combine(';')
      }
    end
    html_options[:class] = ["small_icon", "#{icon}_16", html_options[:class]].combine
    html_options[:id] ||= id
    link_to_remote(
      label,
      options.merge(icon_options),
      html_options
    )
  end

  def link_to_function_with_icon(label, function, options={})
    icon = options.delete(:icon)
    options[:class] = ['small_icon', "#{icon}_16", options[:class]].combine
    link_to_function(label, function, options)
  end

  def link_to_remote_icon(icon, options={}, html_options={})
    html_options[:class] = [html_options[:class], 'small_icon_button'].combine
    html_options[:icon] = icon
    link_to_remote_with_icon('', options, html_options)
  end

  def link_to_function_icon(icon, function, options={})
    link_to_function_with_icon(' ', function, options.merge(:icon=>icon, :class => "small_icon_button #{icon}_16"))
  end

  def link_to_with_icon(icon, label, url, options={})
    options=options.merge(:class => "small_icon #{icon}_16 #{options[:class]}")
    if url
      link_to label, url, options
    else
      content_tag :a, label, options
    end
  end

  def link_to_icon(icon, url, options={})
    link_to_with_icon(icon, '', url, options)
  end

  def link_to_toggle(label, id)
    function = "linkToggle(eventTarget(event), '#{id}')"
    link_to_function_with_icon label, function, :icon => 'right'
  end

#  # makes an icon button to a remote action. when you click on the icon, it turns
#  # into a spinner. when done, the icon returns. any id passed to html_options
#  # is passed on the icon, and not the <a> tag.
#  def link_to_remote_icon(icon, options={}, html_options={})
#    icon_options = {
#      :loading => "event.target.blur();" + spinner_icon_on(icon),
#      :complete => "event.target.blur();" + spinner_icon_off(icon)
#    }
#    link_to_remote(
#      pushable_icon_tag(icon,16,html_options.delete(:id)),
#      options.merge(icon_options),
#      html_options
#    )
#  end
#  def link_to_function_icon(icon, function, html_options={})
#    link_to_function(
#      pushable_icon_tag(icon),
#      function,
#      html_options
#    )
#  end

  private

  def shortcut_key(label)
    label.gsub!(/\[(.)\]/, '<u>\1</u>')
    /<u>(.)<\/u>/.match(label).to_a[1]
  end

  def link_char(links)
    if links.first.is_a? Symbol
      char = links.shift
      return ' &bull; ' if char == :bullet
      return ' ' if char == :none
      return ' | '
    else
      return ' | '
    end
  end

end
