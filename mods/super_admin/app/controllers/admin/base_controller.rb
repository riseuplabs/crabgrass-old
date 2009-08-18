class Admin::BaseController < ApplicationController
  # these helpers are needed for the links added to the admin navigation by this mod
  helper 'admin/users', 'admin/groups', 'admin/memberships'
end

