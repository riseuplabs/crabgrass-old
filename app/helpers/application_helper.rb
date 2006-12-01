# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

#    include FormMaker
  
  # returns the text in the text file, depending on
  # the current locale. The text is processed by markdown.
  def locale_text(filename)
    desired = "#{RAILS_ROOT}/locale/#{Locale.get}/texts/#{filename}.txt"
    default = "#{RAILS_ROOT}/locale/en/texts/#{filename}.txt"
    return markdown(File.read(desired)) if File.exists?(desired)
    return markdown(File.read(default)) if File.exists?(default)
    return _("File '%s' not found") % default
  end

  # display flash messages with appropriate styling
  def display_messages()
    if flash[:notice] || flash[:error] || flash[:update]
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
	  header = "<h2>#{img}#{message}</h2>"
	  "<div class='notice #{type}'>#{header}#{flash[:text].to_s}</div>"
	else
      ""
    end
  end

  def menu_link_to(text, image, options)
    selected="not_selected"
    if @params[:controller] == options[:controller]
#      if (options[:select_on] == :controller) or (@params["action"] == options[:action])
        selected="selected" 
#     end
    end
    #link_to(image_tag("32/"+image,:border=>0) + "<br/>" + text, { :controller=>options[:controller], :action=>options[:action],:id=>@user }, :class=>selected)
    link_to(text, { :controller=>options[:controller], :action=>options[:action],:id=>@user }, :class=>selected)
  end


  def submit_button(label,form_id)
    accesskey = /<u>(.)<\/u>/.match(label).to_a[1]
    %Q[<a href='#' onclick='submit_form("#{form_id}", "#{label}")' class='button' accesskey='#{accesskey}'>#{label}</a>]
  end
  
  def link_button(label,options={})
    accesskey = /<u>(.)<\/u>/.match(label).to_a[1]
    url = url_for options
    %Q[<a href='#{url}' class='button' accesskey='#{accesskey}'>#{label}</a>]
  end

  def post_button(label,options={})
    accesskey = /<u>(.)<\/u>/.match(label).to_a[1]
    link_to(label, options, {:post => true, :class=>'button', :accesskey=>accesskey})
  end
  
  def email_format(content)
    "<pre class='email'>#{h(word_wrap(content,80))}</div>"
  end


end
