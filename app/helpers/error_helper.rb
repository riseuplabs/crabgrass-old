module ErrorHelper

  ##
  ## GENERATING NOTICES
  ##

  #
  # a one stop shopping function for flash messages
  # usage:
  # message :object => @user
  # message :error => 'you messed up good'
  # message :success => 'yeah, you rock'
  #
  ## TODO: destroy with helper, replace with flash_message
  ## and flash_message_now
  def message(opts)    
    if opts[:success]
      flash[:notice] = opts[:success]
    elsif opts[:error]
      flash[:type] = 'error'
      if opts[:later]
        flash[:error] = opts[:error].to_s
      else
        flash.now[:error] = opts[:error].to_s
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

  # options:
  # :title
  # :object | :success | :error
  def add_flash_message(options, flsh)
    flsh[:text] ||= ""
    flsh[:title] = options[:title] || flsh[:title]
    if options[:object]
      object = options[:object]
      unless object.errors.empty?        
        flsh[:type] = 'error'
        flsh[:text] += content_tag :p, "There are problems with the following fields" + ":"
        flsh[:text] += content_tag :ul, object.errors.full_messages.collect { |msg| content_tag :li, msg }
      end
    elsif options[:error] and options[:error].to_s.any?
      flsh[:type] = 'error'
      errors = options[:error].is_a?(Enumerable) ? options[:error] : [options[:error].to_s]
      flsh[:text] += content_tag :ul, errors.collect{|msg| content_tag :li, h(msg)}
    elsif options[:success] and options[:success].any?
      flsh[:type] = 'info'
      flsh[:text] += content_tag :ul, options[:success].to_a.collect{|msg| content_tag :li, h(msg)}
    end
  end

  def flash_message(options)
    add_flash_message(options, flash)
  end

  def flash_message_now(options)
    add_flash_message(options, flash.now)
  end

  ##
  ## DISPLAYING NOTICES
  ##

  # like message() but can be used in rjs templates
  # it uses javascript to rewrite the message area
  # page.replace_html 'message', message_text(:object => @page) unless @page.valid?
  def message_text(option)
    add_flash_message(options, flash)
    display_messages
#    lines = []
#    type = 'info'
#    if opts[:object]
#      object = opts[:object]
#      unless object.errors.empty?
#        type = 'error'
#        title = "Changes could not be saved."
#        text = content_tag(:p, "There are problems with the following fields" + ":")
#        text += content_tag(:ul, object.errors.full_messages.collect { |msg| content_tag("li", msg) })
#      end
#    end
#    build_notice_area(type, title, text)
  end


  # display flash messages with appropriate styling
  def display_messages()
    return "" unless flash[:type]
    unless flash[:title]
      flash[:title] =  "Changes could not be saved" if flash[:type] == 'error'
      flash[:title] =  "Changes saved" if flash[:type] == 'info'
    end
    build_notice_area(flash[:type], flash[:title], flash[:text])
  end

  # use by ajax
  ## TODO: remove, replace with message_text()
  def notify_errors(title, errors)
     text = "<ul>" + errors.collect{|e|"<li>#{e}</li>"}.join("\n") + "</li>"
     build_notice_area('error', title, text)
  end
 
   # use by ajax
  ## TODO: remove, replace with message_text()
  def notify_infos(title, infos)
     text = "<ul>" + infos.collect{|e|"<li>#{e}</li>"}.join("\n") + "</li>"
     build_notice_area('info', title, text)
  end

  private
  
  def build_notice_area(type, title, text)
    img = image_tag("notice/#{type}.png")
    header = content_tag(:h2, img + title)
    content_tag(
     :div, 
     content_tag(
       :div,
       header + text,
       :class => type
     ),
     :class => 'notice'
   )
  end

end

