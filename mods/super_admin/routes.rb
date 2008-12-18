=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :super_admin

this will create the routes
  /admin/groups -> Admin::GroupsController 
  /admin/users  -> Admin::UsersController
  /admin/pages -> Admin::PagesController
  /admin/posts -> Admin::PagesController
  /admin/email_blasts -> Admin::EmailBlastsController
  /admin        -> Admin::BaseController

=end

map.namespace :admin do |admin|
  admin.resources :groups
  admin.resources :users
  admin.resources :memberships
  admin.resources :pages
  admin.resources :posts
  admin.resources :email_blasts
  admin.resources :announcements
  admin.root :controller => 'base'
end

