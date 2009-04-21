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

  protect_from_forgery :secret => Conf.secret

  def index
  end

  helper_method :current_site  # make available to views
  def current_site
    @current_site ||= Site.for_domain(request.host).find(:first)
    @current_site ||= Site.default 
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

