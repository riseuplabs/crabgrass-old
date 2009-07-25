# this requires ActionView::Helpers::TagHelper

module FlashMessageHelper

  ##
  ## GENERATING NOTICES
  ##

  # DEPRECATED
  # DEPRECATED
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
        flash.now[:error] = "Changes could not be saved."[:alert_not_saved]
        flash.now[:text] ||= ""
        flash.now[:text] += content_tag "p", "There are problems with the following fields"[:alert_field_errors] + ":"
        flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
        flash.now[:errors] = object.errors
      end
    end
  end

  #
  # Direct manipulation of the message display:
  #
  #   flash_message :title => 'hello', :text => 'have a nice day', :type => 'info'
  #   flash_message :title => 'wrong', :text => 'you messed up', :type => 'error'
  #
  #
  # Shortcuts:
  #
  #   flash_message :success => true
  #      (same as :type => 'info', :title => 'Changes saved')
  #
  #   flash_message :success => 'yeah'
  #      (same as :type => 'info', :text => 'yeah', :title => 'Changes Saved')
  #
  #   flash_message :error => true
  #      (same as :type => 'error', :title => 'Changes could not be saved')
  #
  #   flash_message :error => 'no'
  #      (same as :type => 'error', :title => 'Changes could not be saved', :text => 'no')
  #
  #   flash_message :success
  #      (same as :success => true)
  #
  #   flash_message :info => 'hi'
  #      (to be used in the future)
  #
  #   flash_message :permission_denied
  #
  # Special objects:
  #
  #   flash_message :exception => exc
  #
  #   flash_message :object => @robot
  #
  # Some things you can add more than once, and they will be appended to the display:
  #
  #   flash_message :error => 'could not save'
  #   flash_message :error => 'and you are doing it wrong'
  #
  # In this case, both errors will be displayed. Other attributes can only be set once,
  # like title or type.
  #
  #
  def flash_message(options)
    add_flash_message(flash, options)
  end

  def flash_message_now(options)
    add_flash_message(flash.now, options)
  end

  ##
  ## DISPLAYING NOTICES
  ##

  # A combination of flash_message and display_messages.
  # It is use in rjs templates.
  #
  # For example:
  #   page.replace_html 'message', message_text(:object => @page) unless @page.valid?
  #
  def message_text(options)
    add_flash_message(flash, options)
    display_messages
  end

  # display flash messages with appropriate styling
  def display_messages(size=:big)
    return "" if flash[:hide]
    @display_message ||= begin
      if flash[:type].empty?
        ""
      else
        if flash[:title] == :skip
          flash[:title] = nil
        elsif flash[:title].empty?
          flash[:title] = "Changes could not be saved"[:alert_not_saved] if flash[:type] == 'error'
          flash[:title] = "Changes saved"[:alert_saved]                  if flash[:type] == 'info'
        end
        notice_contents = build_notice_area(flash[:type], flash[:title], flash[:text])
        content_tag(:div, notice_contents, :class => size.to_s + '_notice')
      end
    end
  end

  #
  # Used in controllers to render an error template base on an exception.
  #
  # for example:
  #
  #   def show
  #     ...
  #   rescue Exception => exc
  #     render_error(exc)
  #   end
  #
  # If flash_message_now(exc) has not yet been called, then this method will
  # call it.
  #
  def render_error(exc=nil)
    unless flash[:type] == 'error'
      flash_message_now :exception => exc
    end
    if exc and exc.is_a? ErrorNotFound
      render :template => 'common/error', :status => 404
    else
      render :template => 'common/error'
    end
  end

  def raise_error(message)
    raise ErrorMessage.new(message)
  end

  def raise_not_found(message)
    raise ErrorNotFound.new(message)
  end

  ##
  ## BUILDING THE MESSAGE
  ## normally, this should not be called directly, but there are a few times
  ## when it is useful.
  ##

  #
  # parses options to build the appropriate objects in the particular flash
  # (flash or flash.now)
  #
  # this method should not be called directly. intead use flash_message and
  # flash_message_now
  #
  # options:
  # :title
  # :object | :success | :error | :exception
  #
  def add_flash_message(flsh, options)
    if options.is_a? Symbol
      options = {options => true}
    end

    flsh[:text] ||= ""
    flsh[:text] += content_tag(:p, options[:text]) if options[:text]
    flsh[:title] = options[:title] || flsh[:title]
    if options[:exception]
      exc = options[:exception]
      if exc.is_a? PermissionDenied
        add_flash_message(flsh, :text => options[:text], :title => 'Permission Denied'[:alert_permission_denied], :error => exc.to_s)
      elsif exc.is_a? ErrorMessages
        add_flash_message(flsh, :text => options[:text], :title => exc.title, :error => exc.errors)
      elsif exc.is_a? ErrorMessage
        add_flash_message(flsh, :text => options[:text], :title => 'Error'[:alert_error], :error => exc.to_s)
      elsif exc.is_a? ActiveRecord::RecordInvalid
        add_flash_message(flsh, :text => options[:text], :object => exc.record)
      else
        add_flash_message(flsh, :title => 'Error'[:alert_error], :error => exc.to_s)
      end
    elsif options[:object]
      object = options[:object]
      unless object.errors.empty?
        flsh[:type] = 'error'
        flsh[:text] += content_tag :p, "There are problems with the following fields"[:alert_field_errors] + ":"
        flsh[:text] += content_tag :ul, object.errors.full_messages.collect { |msg| content_tag :li, msg }
      end
    elsif options[:error]
      flsh[:type] = 'error'
      if options[:error] === true
        # use defaults
      elsif options[:error].any?
        flsh[:text] += content_tag :p, options[:text] if options[:text]
        if options[:error].is_a? Array
          flsh[:text] += content_tag :ul, options[:error].to_a.collect{|msg|
            content_tag :li, h(msg)
          }
        else
          flsh[:text] += content_tag :p, options[:error] if options[:error]
        end
      end
    elsif options[:success]
      flsh[:type] = 'info'
      if options[:success] === true
        # use defaults
      elsif options[:success].any?
        flsh[:text] += content_tag :p, options[:text] if options[:text]
        if options[:success].is_a? Array
          flsh[:text] += content_tag :ul, options[:success].to_a.collect{|msg|
            content_tag :li, h(msg)
          }
        else
          flsh[:text] += content_tag :p, options[:success] if options[:success]
        end
      end
    elsif options[:info]
      options[:title] = options[:info]
      options[:success] = true
      add_flash_message(flsh, options)
    elsif options[:permission_denied]
      add_flash_message(flsh, :title => 'Permission Denied'[:alert_permission_denied])
    else
      flsh[:type] = options[:type]
      flsh[:text] += options[:text]
    end
  end

  private

  def build_notice_area(type, title, text)
    if title
      heading = content_tag(:h2, title, :class => "big_icon #{type}_48")
      heading = content_tag(:div, heading, :class => 'heading')
    else
      heading = ""
    end
    if text and text.any?
      text = content_tag(:div, text, :class => 'text')
    else
      text = ""
    end
    content_tag(:div, heading+text, :class => type)
  end

  def exception_detailed_message(exception)
    message = exception.clean_message
    file, line = exception.backtrace.first.split(":")[0, 2]
    if File.exists?(file)
      message << "\n\n"
      code = File.readlines(file)
      line = line.to_i
      min = [line - 2, 0].max
      max = line + 2
      (min..max).each do |n|
        if n == line
          message << "=> "
        else
          message << "   "
        end
        message << ("%4d" % n)
        message << code[n]
      end
    end
    message
  end
end

