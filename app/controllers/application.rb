# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageUrlHelper
  
  before_filter :login_required, :fetch_page, :breadcrumbs

  # rails lazy loading does work well with namespaced classes, so we help it along: 
  def get_tool_class(tool_class_str)
    klass = Module
    tool_class_str.split('::').each do |const|
       klass = klass.const_get(const)
    end
    unless klass.superclass == Page
      raise Exception.new('page type is not a subclass of page')
    else
      return klass
    end
  end

  # returns a string representation of page class based on the tool_type.
  # if the result in ambiguous, all matching classes are returned as an array.
  # for example:
  #   'poll/rate many' returns 'Tool::RateMany'
  #   'poll'           returns ['Tool::RateOne', 'Tool::RateMany']
  def tool_class_str(tool_type)
    ary = TOOLS.collect{|tool_class| tool_class.to_s if (tool_class.tool_type.starts_with?(tool_type) and not tool_class.internal?)}.compact
    return ary.first if ary.length == 1
    return ary
  end
  
  # override standard url_for to cache the result.
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= super(options))
  #end

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
  
  protected
  
  # to be written by controllers that display pages
  # called before breadcrumbs
  def fetch_page; end 
  
  # a before filter to override by controllers
  def breadcrumbs; end
  
  def add_crumb(crumb_text,crumb_url)
    @breadcrumbs ||= []
    @breadcrumbs << [crumb_text,crumb_url]
  end
  
end
