class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageHelper      # various page helpers needed everywhere
  include UrlHelper       # for user and group urls/links
  include TimeHelper      # for displaying local and readable times
  include ErrorHelper     # for displaying errors and messages to the user
  include PathFinder::Options       # for Page.find_by_path options
  include ContextHelper
      
  # don't allow passwords in the log file.
  filter_parameter_logging "password"
  
  before_filter :set_timezone, :pre_clean, :breadcrumbs, :context, :fetch_site
  around_filter :rescue_authentication_errors
  session :session_secure => true if Crabgrass::Config.https_only
  protect_from_forgery :secret => Crabgrass::Config.secret

  def fetch_site
    @site = Site.default
  end
 
  protected

  def mailer_options
    {:site => @site, :current_user => current_user, :host => request.host,
     :protocol => request.protocol, :port => request.port_string, :page => @page}
  end
  
  # let controllers set a custom stylesheet in their class definition
  def self.stylesheet(*css_files)
    if css_files.any?
      write_inheritable_attribute "stylesheet", css_files
    else
      read_inheritable_attribute "stylesheet"
    end
  end
  
#  def get_unobtrusive_javascript
#    @js_behaviours.to_s
#  end
  
  # let controllers require extra javascript
  def self.javascript(*js_files)
    if js_files.any?
      if js_files.include? :extra
        js_files += ['effects', 'dragdrop', 'controls']
        js_files.delete_if{|i|i==:extra}
      end
      write_inheritable_attribute "javascript", js_files
    else
      read_inheritable_attribute "javascript"
    end
  end
    
  def handle_rss(locals)
    # TODO: rewrite this using the rails 2.0 way, with respond_to do |format| ...
    if params[:path].any? and 
        (params[:path][0] == 'rss' or (params[:path][-1] == 'rss' and params[:path][-2] != 'text'))
      response.headers['Content-Type'] = 'application/rss+xml'   
      render :partial => '/pages/rss', :locals => locals
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
