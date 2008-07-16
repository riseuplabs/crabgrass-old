=begin

Here in lies all the helpers for displaying icons, avatars, spinners, 
and various images.

=end

module ImageHelper

  ##
  ## ICON STYLE
  ##
  ## Some links have icons. Rather than use img tags, which can cause all
  ## kinds of trouble with the layout, crabgrass generally uses background
  ## images for the icon.
  ## 

  ## allows you to change the icon style of an element.
  ## for example, can be used to change the icon of a link
  ## to be a spinner.
  def set_icon_style(element_id, icon)
    unless element_id.is_a? String
      element_id = dom_id(element_id)
    end
    if icon == 'spinner'
      icon_path = '/images/spinner.gif'
    else
      icon_path = "/images/#{icon}"
    end
    "$('%s').style.background = '%s'" % [element_id, "url(#{icon_path}) no-repeat 0% 50%"]
  end

  ## creates an <a> tag with an icon via a background image.
  def link_to_icon(text, icon, path={}, options={})
    link_to text, path, options.merge(:style => icon_style(icon))
  end

  ## return the style css text need to put the icon on the background
  def icon_style(icon)
    size = 16
    url = "/images/#{icon}"
    "background: url(#{url}) no-repeat 0% 50%; padding-left: #{size+8}px;"
  end
   
  ##
  ## AVATARS
  ##
  ## users and groups have avatars. these helpers help you display them.
  ##

  ## creates an img tag based avatar
  def avatar_for(viewable, size='medium', options={})
    image_tag(
      avatar_url(:id => (viewable.avatar_id||0), :size => size),
      :alt => 'avatar', :size => Avatar.pixels(size),
      :class => (options[:class] || "avatar avatar_#{size}")
    )
  end
  
  ## returns the url for the user's or group's avatar
  def avatar_url_for(viewable, size='medium')
    avatar_url(:id => (viewable.avatar_id||0), :size => size)
  end

  ##
  ## PAGES
  ##
  ## every page has an icon. 
  ##

  ## returns the img tag for the page's icon
  def page_icon(page)
    image_tag "pages/#{page.icon}", :size => "22x22"
  end
  
  ## returns css style text to display the page's icon
  def page_icon_style(icon)
   "background: url(/images/pages/#{icon}.png) no-repeat 0% 50%; padding-left: 26px;"
  end

  ##
  ## SPINNER
  ##
  ## spinners are animated gifs that are used to show progress.
  ## these helpers let you create, show, and hide the spinners.
  ##

  def spinner(id, options={})
    display = ("display:none;" unless options[:show])
    options = {:spinner=>"spinner.gif", :style=>"#{display} vertical-align:middle;"}.merge(options)
    "<img src='/images/#{options[:spinner]}' style='#{options[:style]}' id='#{spinner_id(id)}' alt='spinner' />"
  end
  def spinner_id(id)
    if id.instance_of? ActiveRecord::Base
      dom_id(id, 'spinner')
    else
      "#{id.to_s}_spinner"
    end
  end
  def hide_spinner(id)
    "$('%s').hide();" % spinner_id(id)
  end
  def show_spinner(id)
    "$('%s').show();" % spinner_id(id)
  end

end
