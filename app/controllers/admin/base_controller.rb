class Admin::BaseController < ApplicationController
  
  include ActionView::Helpers::TagHelper
  include ErrorHelper
  include AuthenticatedSystem
  
  layout 'admin'
  
  stylesheet('admin')

  helper 'admin/base', 'admin/pages', 'admin/posts', 'admin/email_blasts', 'admin/announcements', 'admin/custom_appearances', PageHelper, UrlHelper, ErrorHelper, LinkHelper, ApplicationHelper, TimeHelper

  
  before_filter :login_required
  before_filter :set_active_tab
  
  include Admin::GroupsHelper
  include Admin::UsersHelper
  include Admin::MembershipsHelper
  include Admin::PagesHelper
  include Admin::PostsHelper
  include Admin::EmailBlastsHelper
  include Admin::AnnouncementsHelper
  
  include ControllerExtension::CurrentSite
  
  protect_from_forgery :secret => Conf.secret
  
  permissions 'admin/base'
  
  def index
  end
  
  private
  
  def set_active_tab
    controller = params[:controller].sub(/admin\//, '')
    action = params[:action]
    @admin_active_tab = "#{controller}_#{action}"
    @active_tab = :admin
  end
  
  protected
  
#  def authorized?
#    if session[:admin]
#      # if session[:admin] is set, then a superadmin user has assumed the identity
#      # of a regular user and is now returning to the admin panel. So we restore
#      # their actual identity.
#      session[:user] = session[:admin]
#      session[:admin] = nil
#      redirect_to '/admin'
#      true
#    end
#  end
end
