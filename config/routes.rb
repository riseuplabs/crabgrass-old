#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
# 

ActionController::Routing::Routes.draw do |map|  

  ##### PLUGIN ROUTES ######################################

  # optionally load these plugin routes, if they happen to be loaded
  map.from_plugin :super_admin rescue NameError
  map.from_plugin :gibberize   rescue NameError

  ##### ASSET ROUTES ######################################
  
  map.connect '/assets/:action/:id',                :controller => 'assets', :action => /create|destroy/
  map.connect 'assets/:id/versions/:version/*path', :controller => 'assets', :action => 'show'
  map.connect 'assets/:id/*path',                   :controller => 'assets', :action => 'show'

  map.avatar 'avatars/:id/:size.jpg', :action => 'show', :controller => 'avatars'
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##### REGULAR ROUTES ####################################
  
  map.connect 'me/inbox/:action/*path',     :controller => 'me/inbox'
  map.connect 'me/requests/:action/*path',  :controller => 'me/requests'
  map.connect 'me/search/*path',    :controller => 'me/search', :action => 'index'
  map.connect 'me/dashboard/:action/*path', :controller => 'me/dashboard'
  map.connect 'me/tasks/:action/*path',     :controller => 'me/tasks'
  map.me      'me/:action/:id', :controller => 'me/base'
  
  map.people  'people/:action/:id', :controller => 'people'
  map.connect 'person/:action/:id/*path', :controller => 'person'
  map.connect 'messages/:user/:action/:id', :controller => 'messages', :action => 'index', :id => nil

  map.groups   'groups/:action/:id', :controller => 'groups'
  map.group    'group/:action/:id', :controller => 'group'
  map.networks 'networks/:action/:id', :controller => 'networks'
  map.network  'network/:action/:id', :controller => 'network'
  map.connect  ':controller/:action/:id/*path', :controller => /group|network/, :action => /tags|archive|calendar|search|discussions/

  map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'
            
  map.connect '', :controller => "account"
  map.login   'account/login',   :controller => 'account',   :action => 'login'
  map.reset_password '/reset_password/:token', :controller => 'account', :action => 'reset_password'

  # routes in emails:
  map.connection '/invites/:action/*path', :controller => 'requests', :action => /accept/

  map.connect 'feeds/assets/:media',        :controller => 'feeds', :action => 'index', :type => 'assets', :requirements => { :media => /all|image|audio|video|document/ }
  map.connect 'feeds/assets/:group/:media', :controller => 'feeds', :action => 'index', :type => 'assets', :media => nil
  map.connect 'feeds/:type/:group', :controller => 'feeds', :action => 'index', :group => nil
  
  # handle all the namespaced base_page controllers:
  map.connect ':controller/:action/:id', :controller => /base_page\/[^\/]+/

  # typically, this is the default route
  map.connect ':controller/:action/:id'
  # This default route was added in Rails 1.2, but we did not add it then;
  # Do we want it?
  # map.connect ':controller/:action/:id.:format'
 

  ##### DISPATCHER ROUTES ###################################
  
  # our default route is sent to the dispatcher
  map.connect 'page/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil
  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil
  # i am not sure what this was for, but it breaks routes for committees. this
  # could be fixed by adding \+, but i am just commenting it out for now. -e
  # :_context => /[\w\.\@\s-]+/

end

# debug routes
#ActionController::Routing::Routes.routes.each do |route|
#  puts route
#end
