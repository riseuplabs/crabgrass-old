class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageUrlHelper
  include UrlHelper
  include ContextHelper
  include TimeHelper

  include PathFinder::Options
      
  # don't allow passwords in the log file.
  filter_parameter_logging "password"
  
  before_filter :set_timezone
  before_filter :pre_clean
  around_filter :rescue_authentication_errors
  before_filter :breadcrumbs, :context
  session :session_secure => true if Crabgrass::Config.https_only
  protect_from_forgery :secret => Crabgrass::Config.secret

 
  protected
  
  # let controllers set a custom stylesheet in their class definition
  def self.stylesheet(*css_files)
    write_inheritable_attribute "stylesheet", css_files if css_files.any?
    read_inheritable_attribute "stylesheet"
  end
  
  def get_unobtrusive_javascript
    @js_behaviours.to_s
  end
  
  # let controllers require extra javascript
  def self.javascript(mode=nil)
    write_inheritable_attribute "javascript", mode if mode
    read_inheritable_attribute "javascript"
  end
    
  def handle_rss(locals)
    # TODO: rewrite this using the rails 2.0 way, with respond_to do |format| ...
    if params[:path].any? and 
        (params[:path][0] == 'rss' or (params[:path][-1] == 'rss' and params[:path][-2] != 'text'))
      response.headers['Content-Type'] = 'application/rss+xml'   
      render :partial => '/pages/rss', :locals => locals
    end
  end


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
  
  private
  
  def pre_clean
    User.current = nil
  end

  def set_timezone
    Time.zone = current_user.time_zone if logged_in?
  end

  def rescue_authentication_errors
    yield
  rescue PermissionDenied
    access_denied
  end
end
