module ErrorHelper

  # a one stop shopping function for flash messages
  def message(opts)    
    if opts[:success]
      flash[:notice] = opts[:success]
    elsif opts[:error]
      if opts[:later]
        flash[:error] = opts[:error]
      else
        flash.now[:error] = opts[:error]
      end
    elsif opts[:object]
      object = opts[:object]
      unless object.errors.empty?
        flash.now[:error] = _("Changes could not be saved.")
        flash.now[:text] ||= ""
        flash.now[:text] += content_tag "p", _("There are problems with the following fields") + ":"
        flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
        flash.now[:errors] = object.errors
      end
    end
  end

  # like message() but can be used in rjs templates
  # it uses javascript to rewrite the message area
  # page.replace_html 'message', message_text(:object => @page) unless @page.valid?
  def message_text(opts)
    lines = []
    type = 'info'
    if opts[:object]
      object = opts[:object]
      unless object.errors.empty?
        type = 'error'
        lines << content_tag("h2", _("Changes could not be saved."))
        lines << content_tag("p", _("There are problems with the following fields") + ":")
        lines << content_tag("ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) })
      end
    end
    content_tag("div", lines.join("\n"), "class" => "notice #{type}")
  end


  # display flash messages with appropriate styling
  def display_messages()
    message_html = ""

    message_html += content_tag("div", 
                                image_tag("notice/info.png") +
                                content_tag("h2", "Notice:") +
                                h($SYSTEM_MESSAGE),
                                "class" => "notice info") if $SYSTEM_MESSAGE

    if flash[:update] or flash[:notice] or flash[:error]
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

      message_html += content_tag("div", img + header + flash[:text].to_s, "class" => "notice #{type}")
    end
    
    message_html
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


end

