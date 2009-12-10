class ApplicationController < ActionController::Base

  helper CommonHelper
  helper PathFinder::Options
  helper Formy
  permissions 'application'

  # TODO: remove these, access via self.view() instead.
  include AuthenticatedSystem
  include PageHelper      # various page helpers needed everywhere
  include UrlHelper       # for user and group urls/links
  include TimeHelper      # for displaying local and readable times
  include FlashMessageHelper     # for displaying errors and messages to the user
  include ContextHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
  include ImageHelper
  include PermissionsHelper

  include PathFinder::Options                   # for Page.find_by_path options
  include ControllerExtension::CurrentSite
  include ControllerExtension::UrlIdentifiers
  include ControllerExtension::RescueErrors

  # don't allow passwords in the log file.
  filter_parameter_logging "password"

  # the order of these filters matters. change with caution.
  before_filter :essential_initialization
  before_filter :set_language
  before_filter :set_timezone, :pre_clean
  before_filter :header_hack_for_ie6
  before_filter :redirect_unverified_user
  before_render :context_if_appropriate

  session :session_secure => Conf.enforce_ssl
  # ^^ TODO: figure out how to use current_site.enforce_ssl instead
  protect_from_forgery :secret => Conf.secret

  # no layout for HTML responses to ajax requests
  layout proc{ |c| c.request.xhr? ? false : 'default' }

  # ensure that essential_initialization ALWAYS comes first
  def self.prepend_before_filter(*filters, &block)
    filter_chain.skip_filter_in_chain(:essential_initialization, &:before?)
    filter_chain.prepend_filter_to_chain(filters, :before, &block)
    filter_chain.prepend_filter_to_chain([:essential_initialization], :before, &block)
  end

  protected

  ##
  ## CALLBACK FILTERS
  ##

  def essential_initialization
    current_site
    @path = parse_filter_path(params[:path])
  end

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

  def redirect_unverified_user
    if logged_in? and current_user.unverified?
      redirect_to account_url(:action => 'unverified')
    end
  end

  # an around filter responsible for setting the current language.
  # order of precedence in choosing a language:
  # (1) the current session
  # (2) the current_user's settings
  # (3) the request's Accept-Language header
  # (4) the site default
  # (5) english
  def set_language
    session[:language_code] ||= begin
      if I18n.available_locales.empty?
        'en'
      elsif !logged_in? || current_user.language.empty?
        code = request.compatible_language_from(I18n.available_locales)
        code ||= current_site.default_language
        code ||= 'en'
        code.to_s.sub('-', '_').sub(/_\w\w/, '')
      else
        current_user.language
      end
    end

    I18n.locale = session[:language_code].to_sym
  end

  # if we have login_required this will be called and check the
  # permissions accordingly
  def authorized?
    may_action?(params[:action])
  end

  # set the current timezone, if the user has it configured.
  def set_timezone
    Time.zone = current_user.time_zone if logged_in?
  end

  # TODO: figure out what the hell is the purpose of this?
  def pre_clean
    User.current = nil
  end

  # A special 'before_render' filter that calls 'context()' if this is a normal
  # request for html and there has not been a redirection. This allows
  # subclasses to put their navigation setup calls in context() because
  # it will only get called when appropriate.
  def context_if_appropriate
    if !@skip_context and normal_request?
      @skip_context = true
      context()
    end
    true
  end
  def context; end

  ##
  ## HELPERS
  ##

  # In a view, we get access to the controller via controller(). The 'view' method
  # lets controllers have access to the view helpers.
  def view
    self.class.helpers
  end

  def current_appearance
    current_site.custom_appearance || CustomAppearance.default
  end
  helper_method :current_appearance

  # create a filter ParsedPath
  def parse_filter_path(path)
    if path.is_a?(PathFinder::ParsedPath)
      path
    elsif path.instance_of?(Array) and path.size == 1 and path[0].is_a?(Hash)
      PathFinder::ParsedPath.new(path[0])
    else
      PathFinder::ParsedPath.new(path)
    end
  end
  helper_method :parse_filter_path

  #
  # returns a hash of options to be given to the mailers. These can be
  # overridden, but these defaults are pretty good. See models/mailer.rb.
  #
  def mailer_options
    from_address = current_site.email_sender.sub('$current_host',request.host)
    from_name    = current_site.email_sender_name.sub('$user_name', current_user.display_name).sub('$site_title', current_site.title)
    opts = {:site => current_site, :current_user => current_user, :host => request.host,
     :protocol => request.protocol, :page => @page, :from_address => from_address,
     :from_name => from_name}
    opts[:port] = request.port_string.sub(':','') if request.port_string.any?
    return opts
  end

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


  # TODO: move to new permission system as soon as it is ready
  helper_method :may_signup?
  def may_signup?
    if current_site.signup_mode == Conf::SIGNUP_MODE[:invite_only]
      session[:user_has_accepted_invite] == true
    elsif current_site.signup_mode == Conf::SIGNUP_MODE[:closed]
      false
    else
      true
    end
  end

  # Returns true if the current request is of type html and we have not
  # redirected. However, IE 6 totally sucks, and sends the wrong request
  # which sometimes appears as :gif.
  def normal_request?
    format = request.format.to_sym
    response.redirected_to.nil? and
    (format == :html or format == :all or format == :gif)
  end

end
