class ApplicationController < ActionController::Base

  helper PageHelper, UrlHelper, Formy, LayoutHelper, LinkHelper, TimeHelper, ErrorHelper, ImageHelper, JavascriptHelper, PathFinder::Options, PostHelper, CacheHelper

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
  before_filter :essential_initialization
  around_filter :set_language
  before_filter :set_timezone, :pre_clean, :breadcrumbs, :context
  around_filter :rescue_authentication_errors
  session :session_secure => Conf.enforce_ssl # todo: figure out how to use current_site.enforce_ssl instead
  protect_from_forgery :secret => Conf.secret
  layout 'default'

  helper_method :current_appearance  # make available to views
  def current_appearance
    current_site.custom_appearance || CustomAppearance.default
  end

  # ensure that essential_initialization ALWAYS comes first
  def self.prepend_before_filter(*filters, &block)
    filter_chain.skip_filter_in_chain(:essential_initialization, &:before?)
    filter_chain.prepend_filter_to_chain(filters, :before, &block)
    filter_chain.prepend_filter_to_chain([:essential_initialization], :before, &block)
  end
  def essential_initialization
    current_site
  end

  protected

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

  #
  # returns a hash of options to be given to the mailers. These can be
  # overridden, but these defaults are pretty good. See models/mailer.rb.
  #
  def mailer_options
    from_address = current_site.email_sender.gsub('$current_host',request.host)
    opts = {:site => current_site, :current_user => current_user, :host => request.host,
     :protocol => request.protocol, :page => @page, :from_address => from_address}
    opts[:port] = request.port_string.sub(':','') if request.port_string.any?
    return opts
  end
  
  # returns true if params[:action] matches one of the args.
  # useful in authorized?() methods.
  def action?(*actions)
    actions.include?(params[:action].to_sym)
  end
  helper_method :action?

  # returns true if params[:controller] matches one of the args.
  def controller?(*controllers)
    controllers.include?(params[:controller].to_sym)
  end
  helper_method :controller?

  # returns true if params[:id] matches the id passed in
  # the arguments may include the id in the form of an integer,
  # string, or active record object.
  def id?(*ids)
    for obj in ids
      if obj.is_a?(ActiveRecord::Base)
        return true if obj.id == params[:id].to_i
      elsif obj.is_a?(Integer) or obj.is_a?(String)
        return true if obj.to_i == params[:id].to_i
      end
    end
    return false
  end
  helper_method :id?

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
          language = LANGUAGES.detect{|l|l.code == current_site.default_language}
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

  ##
  ## SITES
  ##

  public

  # returns the current site. 
  def current_site
    if !@current_site_disabled
      @current_site ||= begin
        site = Site.for_domain(request.host).find(:first)
        site ||= Site.default
        site ||= Site.new(:domain => request.host) 
        Site.current = site # << yes, evil, don't use it! but gibberish still uses it for now.
      end
    else
      Site.new()
    end
  end

  # used for testing
  def disable_current_site
    @current_site_disabled = true
  end

  # used for testing
  def enable_current_site
    @current_site = nil
    @current_site_disabled = false
  end

  helper_method :current_site  # make available to views

end
