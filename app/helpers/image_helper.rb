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
  ## TODO: get rid of this, use class based icons instead
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

  ## creates an <a> tag with an icon via a background image.
  def link_to_icon(text, icon, path={}, options={})
#XXX
    link_to text, path, options.merge(:style => icon_style(icon))
  end

  ## return the style css text need to put the icon on the background
  def icon_style(icon)
#XXX
    size = 16
    url = "/images/#{icon}"
    "background: url(#{url}) no-repeat 0% 50%; padding-left: #{size+8}px;"
  end
  
  def icon_tag(icon, size = 16)
    content_tag :button, '', :class => "icon_#{size} #{icon}_#{size}"
  end

  ##
  ## AVATARS
  ##
  ## users and groups have avatars. these helpers help you display them.
  ##

  ## creates an img tag based avatar
  def avatar_for(viewable, size='medium', options={})
    image_tag(
      avatar_url_for(viewable, size),
      :alt => 'avatar', :size => Avatar.pixels(size),
      :class => (options[:class] || "avatar avatar_#{size}")
    )
  end
  
  ## returns the url for the user's or group's avatar
  def avatar_url_for(viewable, size='medium')
    #avatar_url(:id => (viewable.avatar_id||0), :size => size)
    '/avatars/%s/%s.jpg?%s' % [viewable.avatar_id||0, size, viewable.updated_at.to_i]
  end

  ##
  ## PAGES
  ##
  ## every page has an icon. 
  ##

  ## returns the img tag for the page's icon
  def page_icon(page)
    content_tag :div, '&nbsp;', :class => "page_icon #{page.icon}_16"
#    image_tag "pages/#{page.icon}", :size => "22x22"
  end
  
  ## returns css style text to display the page's icon
  def page_icon_style(icon)
   # XXX
   "background: url(/images/pages/#{icon}.png) no-repeat 0% 50%; padding-left: 26px;"
  end

  ##
  ## SPINNER
  ##
  ## spinners are animated gifs that are used to show progress.
  ## see JavascriptHelper for showing and hiding spinners.
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
  # note: if called directly, thumbnail_img_tag does not actually do the
  #       cropping. rather, it generate a correct img tag for use with 
  #       link_to_asset.
  #
  def thumbnail_img_tag(asset, thumbnail_name,options={}, html_options={})
    thumbnail = asset.thumbnail(thumbnail_name)
    if thumbnail and thumbnail.height and thumbnail.width
      options[:crop] ||= options[:crop!]
      if options[:crop] or options[:scale]
        target_width, target_height = (options[:crop]||options[:scale]).split(/x/).map(&:to_f)
        if target_width > thumbnail.width and target_height > thumbnail.height
          # thumbnail is actually _smaller_ than our target area
          margin_x = ((target_width - thumbnail.width) / 2)
          margin_y = ((target_height - thumbnail.height) / 2)
          img = image_tag(thumbnail.url, html_options.merge(:size => "#{thumbnail.width}x#{thumbnail.height}",
            :style => "padding: #{margin_y}px #{margin_x}px;"))
        elsif options[:crop]
          # extra thumbnail will be hidden by overflow:hidden
          ratio  = [target_width / thumbnail.width, target_height / thumbnail.height].max
          ratio  = [1, ratio].min
          height = (thumbnail.height * ratio).round
          width  = (thumbnail.width * ratio).round
          img = image_tag(thumbnail.url, html_options.merge(:size => "#{width}x#{height}"))
        elsif options[:scale]
          # set image tag to use new scale
          ratio  = [target_width / thumbnail.width, target_height / thumbnail.height, 1].min
          height = (thumbnail.height * ratio).round
          width  = (thumbnail.width * ratio).round
          image_tag(thumbnail.url, html_options.merge(:size => "#{width}x#{height}"))
        end
      else
        image_tag(thumbnail.url, html_options.merge(:size => "#{thumbnail.width}x#{thumbnail.height}"))
      end
    elsif options[:crop!]
      target_width, target_height = options[:crop!].split(/x/).map(&:to_f)
      img = thumbnail_or_icon(asset, thumbnail, target_width, target_height, html_options)
    else
      thumbnail_or_icon(asset, thumbnail, html_options)
    end
  end

  # links to an asset with a thumbnail preview
  def link_to_asset(asset, thumbnail_name, options={})
    thumbnail = asset.thumbnail(thumbnail_name)
    img = thumbnail_img_tag(asset, thumbnail_name,options)
    if size = (options[:crop]||options[:scale]||options[:crop!])
      target_width, target_height = size.split(/x/).map(&:to_f)
    elsif thumbnail and thumbnail.width and thumbnail.height
      target_width = thumbnail.width
      target_height = thumbnail.height
    else
      target_width = 32;
      target_height = 32;     
    end  
    style = "height:#{target_height}px;width:#{target_width}px"
    klass = options[:class] || 'thumbnail'
    url   = options[:url] || asset.url
    link_to img, url, :class => klass, :title => asset.filename, :style => style
  end

  def thumbnail_or_icon(asset, thumbnail, width=nil, height=nil, html_options={})
    if thumbnail
      image_tag(thumbnail.url, html_options)
    else
      mini_icon_for(asset, width, height)
    end
  end

  def icon_for(asset)
    image_tag "/images/png/16/#{asset.big_icon}.png", :style => 'vertical-align: middle'
  end

  def mini_icon_for(asset, width=nil, height=nil)
    if width.nil? or height.nil?
      image_tag "/images/png/16/#{asset.small_icon}.png", :style => 'vertical-align: middle;'
    else
      image_tag "/images/png/16/#{asset.small_icon}.png", :style => "margin: #{(height-22)/2}px #{(width-22)/2}px;"
    end
  end
end
