# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  before_filter :login_required, :breadcrumbs

  # a default success flash
  def flash_success(msg=nil)
    flash[:notice] = msg ? msg : _("Changes saved successfully.")
  end
  
  # sets up the flash to have the current error message
  def flash_error(object_name)
    object = instance_variable_get("@#{object_name}")
    unless object.errors.empty?
      flash.now[:error] = _("Changes could not be saved.")
      flash.now[:text] ||= ""
      flash.now[:text] += content_tag "p", _("There are problems with the following fields") + ":"
      flash.now[:text] += content_tag "ul", object.errors.full_messages.collect { |msg| content_tag("li", msg) }
      flash.now[:errors] = object.errors
    end
  end
  
  def flash_error_msg(msg)
    flash.now[:error] = _("Changes could not be saved.")
    flash.now[:text] = content_tag "p", _("There are problems with the following fields") + ":"
    flash.now[:text] += content_tag "ul", msg
  end

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
  
  def content_tag(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
  
  # TODO: use params to determine how we got here, and generate a page path
  # using that information. ie, if we are at /group/:group_id/page/:page_id
  # then create a path that is based on group and not on user.
  def pagepath(page, options)
    url_for({:controller => 'pages', :action => 'show', :id => page}.merge(options))
  end
  
  # a before filter to override by controllers
  def breadcrumbs; end
  
  def add_crumb(crumb_text,crumb_url)
    @breadcrumbs ||= []
    @breadcrumbs << [crumb_text,crumb_url]
  end
  
end
