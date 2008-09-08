class ApplicationController < ActionController::Base

  include AuthenticatedSystem	
  include PageHelper      # various page helpers needed everywhere
  include UrlHelper       # for user and group urls/links
  include TimeHelper      # for displaying local and readable times
  include ErrorHelper     # for displaying errors and messages to the user
  include PathFinder::Options       # for Page.find_by_path options
  include ContextHelper
  include ActionView::Helpers::TagHelper

  # don't allow passwords in the log file.
  filter_parameter_logging "password"

  # the order of these filters matters. change with caution.
  before_filter :fetch_site
  around_filter :set_language
  before_filter :set_timezone, :pre_clean, :breadcrumbs, :context
  around_filter :rescue_authentication_errors

  session :session_secure => true if Crabgrass::Config.https_only
  protect_from_forgery :secret => Crabgrass::Config.secret
  layout 'default'

  protected

  def fetch_site
    @site = Site.default
  end

  before_filter :header_hack_for_ie6
  def header_hack_for_ie6
    #
    # the default http header cache-control in rails is:
    #    Cache-Control: "private, max-age=0, must-revalidate"
    # on some versions of ie6, this break the back button.
    # so, for ie6, we set it to:
    #    Cache-Control: "max-age=Sun Aug 10 15:18:40 -0700 2008, private"
    # (where the date specified is right now)
    #
    expires_in Time.now if request.user_agent =~ /MSIE 6\.0/
  end

  before_filter :load_template_defaults
  def load_template_defaults
    @footer = render_to_string :partial => 'layouts/footer'
  end

  def mailer_options
    {:site => @site, :current_user => current_user, :host => request.host,
     :protocol => request.protocol, :port => request.port_string, :page => @page}
  end
  
  # let controllers set a custom stylesheet in their class definition
  def self.stylesheet(*css_files)
    if css_files.any?
      sheets = css_files + (read_inheritable_attribute("stylesheet") || [])
      write_inheritable_attribute "stylesheet", sheets
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

  # get the user language from the user profile or use the site default one
  # Gibberish uses lang codes instead of locales.
  # Our default language is 'en_US' and Gibberize default is 'en'.
  def set_language
    # if user is not logged in we query the db on every page load
    # once we are sure we destroy/recreate session on login we can remove
    # this corner case
    if !logged_in?
      if default_language = Language.find_by_name(@site.default_language)
        Gibberish.use_language(default_language.code.to_sym) { yield }
      else
        yield
      end
    elsif !current_user.language.empty?
      Gibberish.use_language(current_user.language.to_sym) { yield }
    else
      if default_language = Language.find_by_name(@site.default_language)
        Gibberish.use_language(default_language.code.to_sym) { yield }
      else
        yield
      end
    end
  end

end
