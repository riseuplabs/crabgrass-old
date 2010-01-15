#
#
# NOTE: make sure to update the validates_handle function whenever you add a new controller
# or a new root path route. This way, group and user handles will not be created for those
# (group name or user login are used as the :context in the default route, so it can't collide
# with any of our other routes).
#

ActionController::Routing::Routes.draw do |map|

  # total hackety magic:
#  map.filter 'crabgrass_routing_filter'

  ##
  ## PLUGINS
  ##

  # optionally load these plugin routes, if they happen to be loaded
  map.from_plugin :super_admin rescue NameError
  map.from_plugin :translator   rescue NameError
  map.from_plugin :moderation  rescue NameError

  map.namespace :admin do |admin|
    admin.resources :announcements
    admin.resources :email_blasts
    admin.resources :users, :only => [:new, :create]
    admin.resources :groups, :only => [:new, :create]
    admin.resources :custom_appearances, :only => [:edit, :update]
    admin.sites 'sites/:action', :controller => 'sites'
    admin.root :controller  => 'base'
  end

  ##
  ## ASSET
  ##

  map.connect '/assets/:action/:id',                :controller => 'assets', :action => /create|destroy/
  map.connect 'assets/:id/versions/:version/*path', :controller => 'assets', :action => 'show'
  map.connect 'assets/:id/*path',                   :controller => 'assets', :action => 'show'

  map.avatar 'avatars/:id/:size.jpg', :action => 'avatar', :controller => 'static'
  map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  ##
  ## ME
  ##

  map.connect 'me/inbox/:action/*path',     :controller => 'me/inbox'
  map.connect 'me/requests/:action/*path',  :controller => 'me/requests'
  map.connect 'me/search/*path',            :controller => 'me/search', :action => 'index'
  map.connect 'me/dashboard/:action/*path', :controller => 'me/dashboard'
  map.connect 'me/tasks/:action/*path',     :controller => 'me/tasks'
  map.connect 'me/infoviz.:format',         :controller => 'me/infoviz', :action => 'visualize'
  map.connect 'me/trash/:action/*path',     :controller => 'me/trash'

  map.resources :messages, { :collection => { :mark => :put },
                             :member => { :next => :get, :previous => :get }} do |message|
    message.resources :posts, :namespace => 'message_'
  end

  map.resources :social_activities, :as => 'social-activities', :only => :index, :collection => { :peers => :get }

  map.with_options(:namespace => 'me/', :path_prefix => 'me') do |me|
    # This should only be index. However ajax calls seem to post not get...
    me.resource :flag_counts, :only => [:show, :create]
    me.resource :recent_pages, :only => [:show, :create]
    me.resource :my_avatar, :as => 'avatar', :controller => 'avatar', :only => :delete
  end

  map.resource :me, :only => [:show, :edit, :update], :controller => 'me'

  ##
  ## PEOPLE
  ##

  map.resources :people_directory, :as => 'directory', :path_prefix => 'people', :controller => 'people/directory'

  map.with_options(:namespace => 'people/') do |people_space|
    people_space.resources :people do |people|
      people.resources :messages, :as => 'messages/public', :controller => 'public_messages'
    end
  end

  map.connect 'person/:action/:id/*path', :controller => 'person'

  ##
  ## EMAIL
  ##

  map.connect '/invites/:action/*path', :controller => 'requests', :action => /accept/
  map.connect '/code/:id', :controller => 'codes', :action => 'jump'

  ##
  ## PAGES
  ##

  # RAILS 2.1 does not support the :only option in resource routing
  # so we have to put my_work above the pages resource so
  # /pages/my_work does not get resolved as Pages#show :id=>"my_work"
  map.with_options(:namespace => 'pages/', :path_prefix => 'pages') do |pages|
    pages.resource :my_work, :only => [:show, :update], :controller => 'pages/my_work'
    pages.resource :notifications, :only => :show, :controller => 'pages/notifications'
    pages.resource :page_flags, :as => 'flags', :only => :update, :controller => 'pages/flags'
  end

  map.resources :pages, :only => [:new, :update, :index]


  map.connect '/pages/*path', :controller => 'pages'

  # handle all the namespaced base_page controllers:
  map.connect ':controller/:action/:id', :controller => /base_page\/[^\/]+/
  #map.connect 'pages/search/*path', :controller => 'pages', :action => 'search'

  ##
  ## OTHER
  ##

  map.login 'account/login',   :controller => 'account',   :action => 'login'
  #map.resources :custom_appearances, :only => [:edit, :update]
  map.reset_password '/reset_password/:token', :controller => 'account', :action => 'reset_password'
  map.account_verify '/verify_email/:token', :controller => 'account', :action => 'verify_email'
  map.account '/account/:action/:id', :controller => 'account'

  map.connect '', :controller => 'root'

  map.connect 'bugreport/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## GROUP
  ##

  map.group_directory 'groups/directory/:action/:id', :controller => 'groups/directory'
  map.network_directory 'networks/directory/:action/:id', :controller => 'networks/directory'

  map.resources :groups do |group|
    group.resources :pages, :only => :new
  end

  map.connect 'groups/:action/:id', :controller => 'groups', :action => /search|archive|discussions|tags|trash|all_content/
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /search|archive|discussions|tags|trash|all_content/

  map.resources :networks do |network|
    network.resources :pages, :only => :new
  end

  map.connect 'networks/:action/:id', :controller => 'networks', :action => /search|archive|discussions|tags|trash/
  map.connect 'networks/:action/:id/*path', :controller => 'networks', :action => /search|archive|discussions|tags|trash/

  ##
  ## CHAT
  ##
  map.chat 'chat/:action/:id', :controller => 'chat'
  map.chat_archive 'chat/archive/:id/date/:date', :controller => 'chat', :action => 'archive'
#  map.connect 'chat/archive/:id/*path', :controller => 'chat', :action => 'archive'
  ##
  ## DEFAULT ROUTE
  ##

  map.connect ':controller/:action/:id'


  ##
  ## DISPATCHER
  ##

  map.connect 'page/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil

  # i am not sure what this was for, but it breaks routes for committees. this
  # could be fixed by adding \+, but i am just commenting it out for now. -e
  # :_context => /[\w\.\@\s-]+/

end

