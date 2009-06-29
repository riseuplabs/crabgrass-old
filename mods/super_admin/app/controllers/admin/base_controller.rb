class Admin::BaseController < ApplicationController
  helper 'admin/users', 'admin/groups', 'admin/memberships'
end

