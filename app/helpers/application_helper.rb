# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include PageUrlHelper
  include UrlHelper
  include Formy
  include LayoutHelper
  include LinkHelper
    
  # display flash messages with appropriate styling
  def display_messages()
    return "" unless flash[:notice] || flash[:error] || flash[:update]
    if flash[:update]
      type = "update"
      message = flash[:update]
    elsif flash[:notice]
      type = "info"
      message = flash[:notice]
    elsif flash[:error]
      type = "error"
      message = flash[:error]
    end
    img = image_tag("notice/#{type}.png")
    header = content_tag("h2", message)
    content_tag("div", img + header + flash[:text].to_s, "class" => "notice #{type}")
  end
  
  # use by ajax
  def notify_errors(title, errors)
     type = "error"
     img = image_tag("notice/#{type}.png")
     header = content_tag("h2", title)
     text = "<ul>" + errors.collect{|e|"<li>#{e}</li>"}.join("\n") + "</li>"
     content_tag("div", img + header + text, "class" => "notice #{type}")
  end
 
   # use by ajax
  def notify_infos(title, infos)
     type = "info"
     img = image_tag("notice/#{type}.png")
     header = content_tag("h2", title)
     text = "<ul>" + infos.collect{|e|"<li>#{e}</li>"}.join("\n") + "</li>"
     content_tag("div", img + header + text, "class" => "notice #{type}")
  end
 
  def page_icon(page)
    image_tag "pages/#{page.icon}", :size => "22x22"
  end
  
  def page_icon_style(icon)
   "background: url(/images/pages/#{icon}.png) no-repeat 0% 50%; padding-left: 26px;"
  end

  def link_to_icon(text, icon, path={}, options={})
    link_to text, path, options.merge(:style => icon_style(icon))
  end

  def icon_style(icon)
    size = 16
    url = "/images/#{icon}"
    "background: url(#{url}) no-repeat 0% 50%; padding-left: #{size+8}px;"
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
    
  def avatar_for(viewable, size='medium', options={})
    #image_tag avatar_url(:viewable_type => viewable.class.to_s.downcase, :viewable_id => viewable.id, :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => 'avatar'
    image_tag avatar_url(:id => (viewable.avatar||0), :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => (options[:class] || "avatar avatar_#{size}")
  end
  
  # makes this: link | link | link
  def link_line(*links)
    "<div class='link_line'>" + links.compact.join(' | ') + "</div>"
  end

  def spinner(id, options={})
    display = ("display:none;" unless options[:show])
    options = {:spinner=>"spinner.gif", :style=>"#{display} vertical-align:middle;"}.merge(options)
    "<img src='/images/#{options[:spinner]}' style='#{options[:style]}' id='#{spinner_id(id)}' alt='spinner' />"
  end
  def spinner_id(id)
    "#{id.to_s}_spinner"
  end
  def hide_spinner(id)
    "Element.hide('#{spinner_id(id)}');"
  end
  def show_spinner(id)
    "Element.show('#{spinner_id(id)}');"
  end


  # override standard url_for to cache the result.
  #alias_method :orig_url_for, :url_for
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= orig_url_for(options))
  #end
  
  # Our goal here it to automatically display the date in the way that
  # makes the most sense. Elusive, i know. If an array of times is passed in
  # we display the newest one. 
  # Here are the current options:
  #   4:30PM    -- time was today
  #   Wednesday -- time was within the last week.
  #   Mar/7     -- time was in the current year.
  #   Mar/7/07  -- time was in a different year.
  # The date is then wrapped in a label, so that if you hover over the text
  # you will see the full details.
  def friendly_date(*times)
    return nil unless times.any?
    time = times.compact.max
    fullstr = full_time(time)
    today = Date.today
    date = time.to_date
    if date == today
      str = time.strftime("%I:%M<span style='font-size: 80%'>%p</span>")
    elsif today > date and (today-date) < 7
      str = time.strftime("%A")
    elsif date.year != today.year
      str = date.loc("%d/%b/%Y")
    else
      str = date.loc('%d/%b')
    end
    "<label title='#{fullstr}'>#{str}</label>"
  end
  
  # formats a time, in full detail
  # for example: Sunday July/3/2007 2:13PM
  def full_time(time)
    '%s %s %s %s' % [time.loc('%A'), time.loc('%d/%b/%Y'), time.loc('%I:%M'), time.period.abbreviation]
  end
  
  def friendly_size(bytes)
    if bytes > 1.megabyte
      '%s MB' % (bytes / 1.megabyte)
    elsif bytes > 1.kilobyte
      '%s KB' % (bytes / 1.kilobyte)
    else
      '%s B' % bytes
    end
  end
  
  
  def created_modified_date(created, modified=nil)
    return friendly_date(created) unless modified and modified != created
    created_date = friendly_date(created)
    modified_date = friendly_date(modified)
    detail_string = "created:&nbsp;#{created_date}<br/>modified:&nbsp;#{modified_date}"
    link_to_function created_date, %Q[this.replace("#{detail_string}")], :class => 'dotted'
  end
  
  # TODO: allow this to be set by the theme
  def favicon
   ret = ''
   ret += '<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />'  if File.exists?("#{RAILS_ROOT}/public/favicon.ico")
   ret += '<link rel="icon" href="/favicon.png" type="image/x-icon" />' if File.exists?("#{RAILS_ROOT}/public/favicon.ico")
  end
 
  def logged_in?
    controller.logged_in?
  end
  
  #
  # used to spit out a column value for a single row.
  # for example:
  #  page_column(page, :title)
  # this function exists so we can re-arrange the columns easily.
  #
  def page_list_cell(page, column, participation)
    if column == :icon
      return page_icon(page)
    elsif column == :checkbox
      check_box('page_checked', page.id, {}, 'checked', '')
    elsif column == :title
      title = link_to(page.title, page_url(page))
      if participation and participation.instance_of? UserParticipation
        title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless participation.resolved?
        title += " " + image_tag("emblems/star.png", :size => "11x11", :title => 'star') if participation.star?
      else
        title += " " + image_tag("emblems/pending.png", :size => "11x11", :title => 'pending') unless page.resolved?
      end
      return title
    elsif column == :updated_by or column == :updated_by_login
      return( page.updated_by_login ? link_to_user(page.updated_by_login) : '&nbsp;')
    elsif column == :created_by or column == :created_by_login
      return( page.created_by_login ? link_to_user(page.created_by_login) : '&nbsp;')
    elsif column == :updated_at
      return friendly_date(page.updated_at)
    elsif column == :created_at
      return friendly_date(page.created_at)
    elsif column == :happens_at
      return friendly_date(page.happens_at)
    elsif column == :group or column == :group_name
      return( page.group_name ? link_to_group(page.group_name) : '&nbsp;')
    elsif column == :contributors_count or column == :contributors
      return page.contributors_count
    else
      return page.send(column)
    end
  end
  
  def page_list_heading(column=nil)
    if column == :group or column == :group_name
      list_heading 'group'.t, 'group_name'
    elsif column == :icon or column == :checkbox
      "<th></th>"
    elsif column == :updated_by or column == :updated_by_login
      list_heading 'updated by'.t, 'updated_by_login'
    elsif column == :created_by or column == :created_by_login
      list_heading 'created by'.t, 'created_by_login'
    elsif column == :updated_at
      list_heading 'updated'.t, 'updated_at'
    elsif column == :created_at
      list_heading 'created'.t, 'created_at'
    elsif column == :happens_at
      list_heading 'happens'.t, 'happens_at'
    elsif column == :contributors_count or column == :contributors
      #"<th>" + image_tag('ui/person-dark.png') + "</th>"
      list_heading image_tag('ui/person-dark.png'), 'contributors_count'
    elsif column
      list_heading column.to_s.t, column.to_s
    end    
  end
  
end
