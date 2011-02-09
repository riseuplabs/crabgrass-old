=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :super_admin

this will create the routes
  /admin/groups -> Admin::GroupsController
  /admin/users  -> Admin::UsersController
=end

map.connect 'locations/index.:format', :controller => 'locations', :action => 'index'
