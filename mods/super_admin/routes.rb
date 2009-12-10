=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :super_admin

this will create the routes
  /admin/groups -> Admin::GroupsController
  /admin/users  -> Admin::UsersController
=end

map.namespace :admin do |admin|
  admin.resources :groups
  admin.resources :users
  admin.resources :memberships
end

