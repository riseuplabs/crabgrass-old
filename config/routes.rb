#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
# 

ActionController::Routing::Routes.draw do |map|  
  # PAGE_TYPES are hardcoded in environment.rb
#  for page in PAGE_TYPES
#    map.connect ":from/:from_id/#{page}/:action/:id",
#     :from => /groups|me|people|networks|places/,
#     :controller => "tool/#{page}",
#     :action => 'show'
#  end

  map.assets 'assets/:id/:filename.:format', :action => 'show', :controller => 'asset'

  # unobtrusive javascript
  #UJS::routes
  
  map.connect 'me/inbox/*path', :controller => 'me', :action => 'inbox'
  map.connect 'me/search/*path', :controller => 'me', :action => 'search'
  map.me 'me/:action/:id', :controller => 'me'
  
  map.people 'people/:action/:id', :controller => 'people'
  map.person 'people/:action/:id', :controller => 'people'
  map.connect 'people/:id/folder/*path', :controller => 'people', :action => 'folder'
  
  map.groups  'groups/:action/:id', :controller => 'groups'
  map.group   'groups/:action/:id', :controller => 'groups'
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /tags|archive|calendar|search/
    
  map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
      
  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars'
  map.connect 'latex/*path.png', :action => 'show', :controller => 'latex'
      
  map.connect '', :controller => "account"
  
  # used for ajax calls to make a direct request bypassing the dispatcher
  map.direct 'page-direct/:page_id/:action/:id/:controller', :controller => /.*/
 
  # typically, this is the default route
  map.connect ':controller/:action/:id'
 
   # a generic route for tool controllers 
  map.connect 'tool/:controller/:action/:id'
  
  # our default route is sent to the dispatcher
  map.connect 'page/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil
end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
