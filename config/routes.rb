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
    admin.resources :widgets, :only => [:index]
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

  # map.connect 'me/inbox/:action/*path',     :controller => 'me/inbox'
  # map.connect 'me/requests/:action/*path',  :controller => 'me/requests'
  # map.connect 'me/dashboard/:action/*path', :controller => 'me/dashboard'
  map.connect 'me/tasks/:action/*path',     :controller => 'me/tasks'
  map.connect 'me/infoviz.:format',         :controller => 'me/infoviz', :action => 'visualize'
  map.connect 'me/pages/trash/:action/*path',     :controller => 'me/trash'
  map.connect 'me/pages/trash',                   :controller => 'me/trash'


  map.with_options(:namespace => 'me/', :path_prefix => 'me') do |me|
    # This should only be index. However ajax calls seem to post not get...
    me.resource :flag_counts, :only => [:show, :create]
    me.resource :recent_pages, :only => [:show, :create]
    me.resource :my_avatar, :as => 'avatar', :controller => 'avatars', :only => :destroy

    me.resources :requests, { :collection => { :mark => :put, :approved => :get, :rejected => :get }}
    # for now removing peers option until we work on fixing friends/peers distinction
    #me.resources :social_activities, :as => 'social-activities', :only => :index, :collection => { :peers => :get }
    me.resources :social_activities, :as => 'social-activities', :only => :index
    me.resources :messages, { :collection => { :mark => :put },
                               :member => { :next => :get, :previous => :get }} do |message|
      message.resources :posts, :controller => 'message_posts'
    end
    me.resources :public_messages, :only => [:show, :create, :destroy]


  end

  map.resource :me, :only => [:show, :edit, :update], :controller => 'me' do |me|
    me.resources :pages,
      :only => [:new, :update, :index],
      :collection => {
  #      :notification => :get,
        :my_work => :get,
        :all => :get,
        :mark => :put}
  end

  map.resources :widgets, :new =>  {:sidebar => :get} do |widget|
    widget.resources :menu_items,
      :only => [:edit, :create, :update, :destroy],
      :collection => {:sort => :put}
  end

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

  map.connect '/me/pages/*path', :controller => 'pages'

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

  map.search 'search/*path', :controller => 'search', :action => 'index'
  map.connect '', :controller => 'root'

  map.connect 'bugreport/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## GROUP
  ##

  map.group_directory 'groups/directory/:action/:id', :controller => 'groups/directory'
  map.connect 'groups/directory/search.:format', :controller => 'groups/directory', :action => 'search'
  map.network_directory 'networks/directory/:action/:id', :controller => 'networks/directory'

  map.resources :groups do |group|
    group.resources :pages, :only => :new
    group.resources :menu_items
  end

  map.connect 'groups/:action/:id', :controller => 'groups', :action => /search|archive|discussions|tags|trash|pages|contributions/
  map.connect 'groups/:action/:id/*path', :controller => 'groups', :action => /search|archive|discussions|tags|trash|pages|contributions/

  map.resources :networks, :collection => {:autocomplete => :get} do |network|
    network.resources :pages, :only => :new
    network.resources :geo_locations, :only => :index
  end

  map.connect 'networks/:action/:id', :controller => 'networks', :action => /search|archive|discussions|tags|trash|contributions/
  map.connect 'networks/:action/:id/*path', :controller => 'networks', :action => /search|archive|discussions|tags|trash|contributions/

  ##
  ## CHAT
  ##
  map.chat 'chat/:action/:id', :controller => 'chat'
  map.chat_archive 'chat/archive/:id/date/:date', :controller => 'chat', :action => 'archive'
#  map.connect 'chat/archive/:id/*path', :controller => 'chat', :action => 'archive'

  ## for maps
  map.resources :geo_locations

  ##
  ## DEFAULT ROUTE
  ##

  map.connect ':controller/:action/:id'


  if RAILS_ENV == "development"
    ## DEBUG ROUTE
    map.debug_become 'debug/become', :controller => 'debug', :action => 'become'
  end


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

