# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
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
  
  def selected(condition)
    'class="selected"' if condition
  end
  
  def icon(pagetype,size=16)
    img = case pagetype
      when "Poll::Poll"; 'check'
      else; 'bubble'
    end
    image_tag "#{size}/#{img}.png", :size => "#{size}x#{size}"
  end
 
  def link_to_page(text, page)
    controller = case page.tool_type
      when "Poll::Poll"; 'polls'
      when "Text::Text"; 'texts'
      else; 'pages'
    end
    link_to( (text||'&nbsp;'), :controller => controller, :action => 'show', :id => page)
  end 
  
  def link_to_user(user)
    link_to user.login, :controller => 'people', :action => 'show', :id => user
  end
  #def user_path(user)
  #  url_for :controller => 'person', :action => 'show', :id => user
  #end
  
  def posts_path(options)
    "yikes"
  end
  
  def avatar_for(user, size=32)
    image_tag "person.png", :size => "#{size}x#{size}", :class => 'photo'
  end
  
  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end
  
end
