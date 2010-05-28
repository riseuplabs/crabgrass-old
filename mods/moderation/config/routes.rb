=begin

include this in config/routes.rb to activate these routes:

  map.from_plugin :super_admin

this will create the routes
  /admin/pages -> Admin::PagesController
  /admin/posts  -> Admin::PostsController
=end

ActionController::Routing::Routes.draw do |map|
  map.namespace :admin do |admin|
    admin.resources :pages
    admin.resources :wall_posts
    admin.resources :discussion_posts
    admin.resources :chat_messages
  end
end
