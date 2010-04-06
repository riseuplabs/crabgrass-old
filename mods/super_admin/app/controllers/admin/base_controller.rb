class Admin::BaseController < ApplicationController
  # these helpers are needed for the links added to the admin navigation by this mod
  helper 'admin/users', 'admin/groups', 'admin/memberships'


  prepend_before_filter :restore_superadmin, :only => :index

  def restore_superadmin
    if session[:admin]
      # if session[:admin] is set, then a superadmin user has assumed the identity
      # of a regular user and is now returning to the admin panel. So we restore
      # their actual identity.
      session[:user] = session[:admin]
      session[:admin] = nil
      redirect_to :action => :index
    end
  end
end

