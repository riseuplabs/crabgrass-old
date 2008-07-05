class Admin::BaseController < ActionController::Base

  include ErrorHelper
  include AuthenticatedSystem

  layout 'admin'
  helper 'admin/users', 'admin/groups', 'admin/memberships', 'admin/base'
  before_filter :login_required
  
  include Admin::GroupsHelper
  include Admin::UsersHelper
  include Admin::MembershipsHelper

  protect_from_forgery :secret => Crabgrass::Config.secret

  def index
  end

  protected

  def authorized?
    @site = Site.default
    @site.super_admins and @site.super_admins.include?(current_user.login)
  end

end

