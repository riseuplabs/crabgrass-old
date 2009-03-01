class ApplicationController < ActionController::Base

  helper PageHelper, UrlHelper, Formy, LayoutHelper, LinkHelper, TimeHelper, ErrorHelper, ImageHelper, JavascriptHelper, PathFinder::Options, PostHelper

  # TODO: remove these, access via ActionController::Base.helpers() instead.
  include AuthenticatedSystem	
  include PageHelper      # various page helpers needed everywhere
  include UrlHelper       # for user and group urls/links
  include TimeHelper      # for displaying local and readable times
  include ErrorHelper     # for displaying errors and messages to the user
  include PathFinder::Options       # for Page.find_by_path options
  include ContextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ImageHelper

  # don't allow passwords in the log file.
  filter_parameter_logging "password"
  

  # the order of these filters matters. change with caution.
  prepend_before_filter :fetch_site # needs to come before fetch_profile in
                                    # profile controller
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

  def mailer_options
    opts = {:site => @site, :current_user => current_user, :host => request.host,
     :protocol => request.protocol, :page => @page}
    opts[:port] = request.port_string.sub(':','') if request.port_string.any?
    return opts
  end
  
  # returns true if params[:action] matches one of the args.
  # useful in authorized?() methods.
  def action?(*actions)
    actions.include?(params[:action].to_sym)
  end
  helper_method :action?

  # rather than include every stylesheet in every request, some stylesheets are 
  # only included "as needed". A controller can set a custom stylesheet
  # using 'stylesheet' in the class definition:
  #
  # for example:
  #   
  #   stylesheet 'gallery', 'images'
  #   stylesheet 'page_creation', :action => :create
  #
  # as needed stylesheets are kept in public/stylesheets/as_needed
  #
  def self.stylesheet(*css_files)
    if css_files.any?
      options = css_files.last.is_a?(Hash) ? css_files.pop : {}
      sheets  = read_inheritable_attribute("stylesheet") || {}
      index   = options[:action] || :all
      sheets[index] ||= []
      sheets[index] << css_files       
      write_inheritable_attribute "stylesheet", sheets
    else
      read_inheritable_attribute "stylesheet"
    end
  end
   
  # let controllers require extra javascript
  # for example:
  #
  #   javascript 'wiki_edit', :action => :edit
  #
  def self.javascript(*js_files)
    if js_files.any?
      options = js_files.last.is_a?(Hash) ? js_files.pop : {}
      scripts  = read_inheritable_attribute("javascript") || {}
      index   = options[:action] || :all
      scripts[index] ||= []
      scripts[index] << js_files       
      write_inheritable_attribute "javascript", scripts
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
      return true
    else
      return false
    end
  end
     
  # some helpers we include in controllers. this allows us to 
  # grab the controller that will work in a view context and a
  # controller context.
  def controller
    self
  end 

  # note: this method is not automatically called. if you want to enable HTTP
  # authentication for some action(s), you must put a prepend_before_filter in
  # place.
  # however, a user who successfully uses HTTP auth on an action for which it
  # was enabled will stay logged in and can then go and see other things.
  # this is kind of lame. but only exploitable by people who could log in
  # anyway, so presumabbly not *too* big a security hole.
  def login_with_http_auth
    unless logged_in?
      authenticate_or_request_with_http_basic do |user, password|
        founduser = User.authenticate(user, password)
        self.current_user = founduser unless founduser.nil?
      end
    end
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
  rescue ActionController::InvalidAuthenticityToken
    render :template => 'account/csrf_error'
  rescue PermissionDenied
    access_denied
  end

  # an around filter responsible for setting the current language.
  # order of precedence in choosing a language:
  # (1) the current session
  # (2) the current_user's settings
  # (3) the site default
  # (4) english
  def set_language
    if LANGUAGES.any?
      session[:language_code] ||= begin
        if !logged_in? or current_user.language.nil?
          language = LANGUAGES.detect{|l|l.code == @site.default_language}
          language ||= LANGUAGES.detect{|l|l.code == 'en_US'}
          language_code = language.code.to_sym
        else
          language_code = current_user.language.to_sym
        end
      end
    else
      session[:language_code] = 'en_US'
    end
    if session[:language_code]
      Gibberish.use_language(session[:language_code]) { yield }
    else
      yield
    end
  end
 
  ## handy way to get back where we came from
  def store_back_url(url=nil)
    url ||= referer
    session[:where_we_came_from] = url
  end
  def redirect_to_back_url
    url = session[:where_we_came_from]
    session[:where_we_came_from] = nil
    redirect_to url
  end


  # override the standard rails rescues_path in order to be able to specify
  # our own templates.
  helper_method :rescues_path
  def rescues_path(template_name)
    file = "#{RAILS_ROOT}/app/views/rescues/#{template_name}.erb"   
    if File.exists?(file)
      return file
    else
      return super(template_name)
    end
  end



end
