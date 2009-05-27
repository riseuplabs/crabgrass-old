class Admin::BaseController < ActionController::Base

  include ActionView::Helpers::TagHelper 
  include ErrorHelper
  include AuthenticatedSystem

  layout 'admin'

  helper 'admin/users', 'admin/groups', 'admin/memberships', 'admin/base', 'admin/pages', 'admin/posts', 'admin/email_blasts', 'admin/announcements', PageHelper, UrlHelper, ErrorHelper, LinkHelper, ApplicationHelper, TimeHelper

  before_filter :login_required

  include Admin::GroupsHelper
  include Admin::UsersHelper
  include Admin::MembershipsHelper
  include Admin::PagesHelper
  include Admin::PostsHelper
  include Admin::EmailBlastsHelper
  include Admin::AnnouncementsHelper

  include ControllerExtension::CurrentSite

  protect_from_forgery :secret => Conf.secret

  def index
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
 
  # using expire_frament et al. doesn't work here because generating the keys
  # requires knowledge of the context where the fragment is shown. however,
  # some fragments need expire after certain superadmin actions (e.g. removing
  # a committee outdates the cached committee avatars for group landing, see
  # #700, #332 and many more)
  def clear_cache
    begin
      system("cd #{RAILS_ROOT} && rake tmp:cache:clear")
      flash[:notice] = "Cache cleared!"
    rescue => exc
      logger.fatal("Clearing cache failed!!! (#{exc.class}: #{exc.message})")
      flash[:errors] = "Clearing cache failed. Please check the server logs for details."
    end
    redirect_to :action => 'index'
  end
 
  protected

  def authorized?
    if session[:admin]
      # if session[:admin] is set, then a superadmin user has assumed the identity
      # of a regular user and is now returning to the admin panel. So we restore
      # their actual identity.
      session[:user] = session[:admin]
      session[:admin] = nil
      redirect_to '/admin'
      true
    else
      current_user.superadmin?
    end
  end
end

