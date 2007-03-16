# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  include PageUrlHelper
  include Formy
#  Formy::define_formy_keywords
  
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
    img = image_tag("48/#{type}.png")
    header = content_tag("h2", message)
    content_tag("div", img + header + flash[:text].to_s, "class" => "notice #{type}")
  end
    
  def page_icon(page,size=16)
    #image_tag "#{size}/#{page.icon}", :size => "#{size}x#{size}"
    image_tag "pages/#{page.icon}", :size => "22x22"
  end
 
 #this function needs to go far far away
  #def link_to_page(text, page)
  #  controller = case page.tool_type
  #    when "Poll::Poll"; 'polls'
  #    when "Decider::Text"; 'texts'
  #    when "Text::Text"; 'texts'
  #    else; 'pages'
  #  end
  #  link_to( (text||'&nbsp;'), :controller => 'pages', :action => 'show', :id => page)
  #end 
    
  # arg might be a user object, a user id, or the user's login
  def link_to_user(arg)
    if arg.is_a? Integer
      login = User.find(arg).login
    elsif arg.is_a? String
      login = arg
    elsif arg.is_a? User
      login = arg.login
    end
    link_to login, :controller => '/people', :action => 'show', :id => login if login
  end

 def link_to_group(group)
    link_to group.name, :controller => '/groups', :action => 'show', :id => group
  end
  #def user_path(user)
  #  url_for :controller => 'person', :action => 'show', :id => user
  #end
    
  def avatar_for(viewable, size='medium')
    #image_tag avatar_url(:viewable_type => viewable.class.to_s.downcase, :viewable_id => viewable.id, :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => 'avatar'
    image_tag avatar_url(:id => (viewable.avatar||0), :size => size), :alt => 'avatar', :size => Avatar.pixels(size), :class => 'avatar'
  end
  
  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end
  
  def link_to_breadcrumbs
    if @breadcrumbs and @breadcrumbs.length > 1
      @breadcrumbs.collect{|b| link_to b[0],b[1]}.join ' &raquo; ' 
    end
  end
  
  def first_breadcrumb
    @breadcrumbs.first.first if @breadcrumbs.any?
  end
  
  def title_from_breadcrumbs
    (
      (@breadcrumbs||[]).collect{|b|truncate(b[0])}.reverse +
      [SITE_NAME]
    ).join(' : ')
  end

  # override standard url_for to cache the result.
  #alias_method :orig_url_for, :url_for
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= orig_url_for(options))
  #end
  
  def friendly_date(*times)
    return nil unless times.any?
    time = times.compact.max
    today = Date.today
    date = time.to_date
    if date == today
      time.strftime("%I:%M%p")
    elsif today > date and (today-date) < 7
      time.strftime("%A")
    elsif date.year != today.year
      date.loc("%d/%b/%Y")
    else
      date.loc('%d/%b')
    end
  end
  
end
