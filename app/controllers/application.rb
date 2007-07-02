class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageUrlHelper
  include UrlHelper
  include ContextHelper
  include PageFinders
  
  # don't allow passwords in the log file.
  filter_parameter_logging "password"
  
  before_filter :login_required, :breadcrumbs, :context
  
  # let controllers set a custom stylesheet in their class definition
  def self.stylesheet(cssfile=nil)
    write_inheritable_attribute "stylesheet", cssfile if cssfile
    read_inheritable_attribute "stylesheet"
  end
  
  # rails lazy loading does work well with namespaced classes, so we help it along: 
  def get_tool_class(tool_class_str)
    klass = Module
    tool_class_str = tool_class_str.to_s
    tool_class_str.split('::').each do |const|
       klass = klass.const_get(const)
    end
    unless klass.superclass == Page
      raise Exception.new('page type is not a subclass of page')
    else
      return klass
    end
  end

  def str_to_page_class()
      
  end
  
  # returns a string representation of page class based on the tool_type.
  # if the result in ambiguous, all matching classes are returned as an array.
  # for example:
  #   'poll/rate many' returns 'Tool::RateMany'
  #   'poll'           returns ['Tool::RateOne', 'Tool::RateMany']
  #def tool_class_str(tool_type)
  #  ary = TOOLS.collect{|tool_class| tool_class.to_s if (tool_class.tool_type.starts_with?(tool_type) and not tool_class.internal?)}.compact
  #  return ary.first if ary.length == 1
  #  return ary
  #end
  
  # override standard url_for to cache the result.
  #def url_for(options = {})
  #  @@cached_urls ||= {}
  #  return(@@cached_urls[options.to_yaml] ||= super(options))
  #end

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
  
  def content_tag(tag, content)
    "<#{tag}>#{content}</#{tag}>"
  end
   
  # some helpers we include in controllers. this allows us to 
  # grab the controller that will work in a view context and a
  # controller context.
  def controller
    self
  end 
end
