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
  def set_icon_style(element_id, icon, position="0% 50%")
    unless element_id.is_a? String
      element_id = dom_id(element_id)
    end
    if icon == 'spinner'
      icon_path = '/images/spinner.gif'
    else
      icon_path = "/images/#{icon}"
    end
    "$('%s').style.background = '%s'" % [element_id, "url(#{icon_path}) no-repeat #{position}"]
  end

  def add_class_name(element_id, class_name)
    unless element_id.is_a? String
      element_id = dom_id(element_id)
    end
    "$('%s').addClassName('%s')" % [element_id, class_name]
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
    if id.is_a? ActiveRecord::Base
      id = dom_id(id, 'spinner')
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

  ##
  ## ASSET THUMBNAILS
  ##

  #
  # creates an img tag for a thumbnail, optionally scaling the image or cropping
  # the image to meet new dimensions (using html/css, not actually scaling/cropping)
  #
  # eg: thumbnail_img_tag(thumb, :crop => '22x22')
  # 
  # options:
  #  * :crop   -- the img is first scaled, then cropped to allow it to
  #               optimally fit in the cropped space.
  #  * :scale  -- the img is scaled, preserving proportions 
  #  * :crop!  -- crop, even if there is no known height and width
  #
  def thumbnail_img_tag(thumbnail,options={})
    return nil unless thumbnail
    if thumbnail.height and thumbnail.width
      options[:crop] ||= options[:crop!]
      if options[:crop] or options[:scale]
        target_width, target_height = (options[:crop]||options[:scale]).split(/x/).map(&:to_f)
        if target_width > thumbnail.width and target_height > thumbnail.height
          # thumbnail is actually _smaller_ than our target area
          margin_x = ((target_width - thumbnail.width) / 2).round
          margin_y = ((target_height - thumbnail.height) / 2).round
          img = image_tag(thumbnail.url, :size => "#{thumbnail.width}x#{thumbnail.height}",
            :style => "margin: #{margin_y}px #{margin_x}px;")
          content_tag(:div, img, :style => "height:#{target_height}px;width:#{target_width}px")
        elsif options[:crop]
          # extra thumbnail will be hidden by overflow:hidden
          ratio  = [target_width / thumbnail.width, target_height / thumbnail.height].max
          ratio  = [1, ratio].min
          height = (thumbnail.height * ratio).round
          width  = (thumbnail.width * ratio).round
          img = image_tag(thumbnail.url, :size => "#{width}x#{height}")
          content_tag(:div, img,
           :style => "overflow:hidden;height:#{target_height}px;width:#{target_width}px")
        elsif options[:scale]
          # set image tag to use new scale
          ratio  = [target_width / thumbnail.width, target_height / thumbnail.height, 1].min
          height = (thumbnail.height * ratio).round
          width  = (thumbnail.width * ratio).round
          image_tag(thumbnail.url, :size => "#{width}x#{height}")
        end
      else
        image_tag(thumbnail.url, :size => "#{thumbnail.width}x#{thumbnail.height}")
      end
    elsif options[:crop!]
      target_width, target_height = options[:crop!].split(/x/).map(&:to_f)
      img = image_tag(thumbnail.url)
      content_tag(:div, img, :style => 
        "overflow:hidden;height:#{target_height}px;width:#{target_width}px")
    else
      image_tag(thumbnail.url)
    end
  end

end
