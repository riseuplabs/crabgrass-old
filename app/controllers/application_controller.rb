module UI
end

module Utility
end

class ApplicationController < ActionController::Base

  # permissions 'application'

  ##
  ## GLOBAL HELPERS
  ##

  # note: if there is an error in any of the helpers or controller extensions, 
  # for some reason rails does not report the error correctly. It will say that
  # helper/ui/error_helper.rb does not define UI::ErrorHelper. I have found that
  # loading ApplicationController from the console can correctly identify the
  # real error. 

  include UI::FlashMessageHelper   # for displaying errors and messages to the user
  helper UI::FlashMessageHelper    # load early, in case an error occurs

  helper PathFinder::Options
  helper Crabgrass::Hook::Helper

  helper Utility::CacheHelper
  helper Utility::GeneralHelper
  helper Utility::PermissionsHelper
  helper Utility::RouteHelper
  helper Utility::RssHelper
  helper Utility::TimeHelper

  helper UI::ContextHelper
  helper UI::EntityUrlHelper
  helper UI::EntityDisplayHelper
  helper UI::HelpHelper
  helper UI::FormHelper
  helper UI::ImageHelper
  helper UI::JavascriptHelper
  helper UI::LayoutHelper
  helper UI::LinkHelper
  helper UI::MenuHelper         # deprecated
  helper UI::ModalboxHelper
  helper UI::PaginationHelper
  helper UI::PostHelper
  helper UI::SearchHelper
  helper UI::TabBarHelper       # deprecated
  helper UI::TaggingHelper
  helper UI::TextHelper

  helper Page::CreationHelper
  helper Page::FormHelper
  helper Page::ListingHelper
  helper Page::ListingTableHelper
  helper Page::UrlHelper

  # TODO: figure out why each of these is here and then remove it. 
  # if still needed, access via self.view() instead.
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper
#  include Pages::PageHelper        # various page helpers needed everywhere
  include Utility::TimeHelper      # for displaying local and readable times
  # include Utility::RouteHelper  
  # include UI::DisplayEntityHelper
  include UI::ImageHelper
  include UI::LinkHelper
  include UI::EntityUrlHelper

  ##
  ## CONTROLLER EXTENSIONS
  ## 

  include AuthenticatedSystem
  include Utility::PermissionsHelper
  include PathFinder::Options
  include ControllerExtension::Context
  include ControllerExtension::CurrentSite
  include ControllerExtension::UrlIdentifiers
  include ControllerExtension::RescueErrors
  include ControllerExtension::PaginationOptions
  include Crabgrass::Hook::Helper

  ##
  ## FILTERS
  ##

  # don't allow passwords in the log file.
  filter_parameter_logging "password"

  # the order of these filters matters. change with caution.
  before_filter :essential_initialization
  before_filter :set_language
  before_filter :set_timezone, :pre_clean
  before_filter :header_hack_for_ie6
  before_filter :redirect_unverified_user
  before_render :context_if_appropriate
  before_filter :enforce_ssl_if_needed

  def enforce_ssl_if_needed
    request.session_options[:secure] = current_site.enforce_ssl
  end

  protect_from_forgery

  # no layout for HTML responses to ajax requests
  layout proc{ |c| c.request.xhr? ? false : 'base' }

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
    @skip_context = false
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
    # User.current = nil
  end

  ##
  ## HELPERS
  ##

  # In a view, we get access to the controller via controller(). The 'view' method
  # lets controllers have access to the view helpers.
  def view
    self.class.helpers
  end

  def current_theme
    #@current_theme ||= Theme[current_site.theme_name]
    @current_theme ||= Crabgrass::Theme["default"]
  end
  helper_method :current_theme

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

  # controllers should call this when they want to record a tracking event.
  # e.g. in order to update the page view count.
  def track(options={})
    if current_site.tracking
      Tracking.delayed_insert({:current_user => current_user, :group => @group, :user => @user, :action => :view}.merge(options))
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
