# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require 'gettext/rails'

class ApplicationController < ActionController::Base

  init_gettext "nest", "UTF-8", "text/html"
  
  include AuthenticatedSystem	
  before_filter :login_required


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

  def content_tag(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
  
end
