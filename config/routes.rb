#
# NOTE: make sure to update FORBIDDEN_NAMES with any words that are used by routes
# and cannot be used for group or user names.
#

FORBIDDEN_NAMES = %w(account admin assets avatars chat code debug do groups javascripts me networks page pages people places issues static stats stylesheets).freeze

ActionController::Routing::Routes.draw do |map|
  map.resources :examples



#  map.namespace :admin do |admin|
#    admin.resources :announcements
#    admin.resources :email_blasts
#    admin.resources :users, :only => [:new, :create]
#    admin.resources :groups, :only => [:new, :create]
#    admin.resources :custom_appearances, :only => [:new, :edit, :update]
#    admin.sites 'sites/:action', :controller => 'sites'
#    admin.root :controller  => 'base'
#  end

  ##
  ## STATIC FILES AND ASSETS
  ##

  map.with_options(:controller => 'assets') do |assets|
    assets.connect '/assets/:action/:id', :action => /create|destroy/
    assets.connect 'assets/:id/versions/:version/*path', :action => 'show'
    assets.connect 'assets/:id/*path', :action => 'show'
  end

  map.avatar 'avatars/:id/:size.jpg', :action => 'avatar', :controller => 'static'
  # map.connect 'latex/*path', :action => 'show', :controller => 'latex'

  map.connect 'theme/:name/*file.css', :controller => 'theme', :action => 'show'

  ##
  ## ME
  ##

#  # map.connect 'me/inbox/:action/*path',     :controller => 'me/inbox'
#  # map.connect 'me/requests/:action/*path',  :controller => 'me/requests'
#  # map.connect 'me/dashboard/:action/*path', :controller => 'me/dashboard'
#  map.connect 'me/tasks/:action/*path',     :controller => 'me/tasks'
#  map.connect 'me/infoviz.:format',         :controller => 'me/infoviz', :action => 'visualize'
#  map.connect 'me/pages/trash/:action/*path',     :controller => 'me/trash'
#  map.connect 'me/pages/trash',                   :controller => 'me/trash'


#  map.with_options(:namespace => 'me/', :path_prefix => 'me') do |me|
#    # This should only be index. However ajax calls seem to post not get...
#    me.resource :flag_counts, :only => [:show, :create]
#    me.resource :recent_pages, :only => [:show, :create]
#    me.resource :my_avatar, :as => 'avatar', :controller => 'avatars', :only => :destroy

#    me.resources :requests, { :collection => { :mark => :put, :approved => :get, :rejected => :get }}
#    # for now removing peers option until we work on fixing friends/peers distinction
#    #me.resources :social_activities, :as => 'social-activities', :only => :index, :collection => { :peers => :get }
#    me.resources :social_activities, :as => 'social-activities', :only => :index
#    me.resources :messages, { :collection => { :mark => :put },
#                               :member => { :next => :get, :previous => :get }} do |message|
#      message.resources :posts, :controller => 'message_posts'
#    end
#    me.resources :public_messages, :only => [:show, :create, :destroy]

  map.with_options(:namespace => 'me/', :path_prefix => 'me', :name_prefix => 'me_') do |me|
    me.resources :timelines
    me.home      '', :controller => 'timelines', :action => 'index'
    me.resource  :page, :only => [:new, :create]
    me.pages     'pages/*path', :controller => 'pages'
    me.resources :activities
    me.resources :messages
    me.resource  :settings, :only => [:show, :update]
    me.resources :permissions
    me.resource  :profile, :controller => 'profile'
    me.resources :requests
  end

#  end

#  map.resource :me, :only => [:show, :edit, :update], :controller => 'me' do |me|
#    me.resources :pages,
#      :only => [:new, :update, :index],
#      :collection => {
#  #      :notification => :get,
#        :my_work => :get,
#        :all => :get,
#        :mark => :put}
#  end

  ##
  ## PEOPLE
  ##

  map.people_directory 'people/directory/*path', :controller => 'people/directory'

  map.resources :people, :namespace => 'people/' do |people|
    people.resource  :page, :only => [:new, :create]
    people.pages     'pages/*path', :controller => 'pages'
    people.resources :messsages
    people.resources :activities
    people.resources :pages
  end

  # map.resources :people_directory, :as => 'directory', :path_prefix => 'people', :controller => 'people/directory'
  
#  map.with_options(:namespace => 'people/') do |people_space|
#    people_space.resources :people do |people|
#      people.resources :messages, :as => 'messages/public', :controller => 'public_messages'
#    end
#  end

#  map.connect 'person/:action/:id/*path', :controller => 'person'

  ##
  ## EMAIL
  ##

  map.connect '/invites/:action/*path', :controller => 'requests', :action => /accept/
  map.connect '/code/:id', :controller => 'codes', :action => 'jump'

  ##
  ## ACCOUNT
  ##

  map.with_options(:controller => 'account') do |account|
    account.login 'account/login', :action => 'login'
    account.reset_password 'account/reset_password/:token', :action => 'reset_password'
    account.account_verify 'account/verify_email/:token', :action => 'verify_email'
    account.connect 'account/:action/:id'
  end

  ##
  ## GROUP
  ##

  map.networks_directory 'networks/directory/*path', :controller => 'groups/networks_directory'
  map.groups_directory 'groups/directory/*path', :controller => 'groups/groups_directory'

  map.resources :groups, :networks, :namespace => 'groups/' do |groups|
    # groups.resource  :page, :only => [:new, :create]
    groups.pages     'pages/*path', :controller => 'pages' #, :path => []
    groups.resources :members
    groups.resources :requests
    groups.resources :invites
    groups.resource  :settings, :only => [:show, :update]
  end

  ##
  ## CHAT
  ##
#  map.chat 'chat/:action/:id', :controller => 'chat'
#  map.chat_archive 'chat/archive/:id/date/:date', :controller => 'chat', :action => 'archive'
##  map.connect 'chat/archive/:id/*path', :controller => 'chat', :action => 'archive'

  ##
  ## DEBUGGING
  ##

  if RAILS_ENV == "development"
    ## DEBUG ROUTE
    map.debug_become 'debug/become', :controller => 'debug', :action => 'become'
  end
  map.debug_report 'debug/report/submit', :controller => 'bugreport', :action => 'submit'

  ##
  ## DEFAULT ROUTE
  ##

  map.connect '/do/:controller/:action/:id'
  map.root :controller => 'root'

  ##
  ## PAGES
  ##

  map.connect '/pages/:controller/:action/:id', :controller => /base_page\/[^\/]+/

  map.connect 'pages/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context/:_page/:_page_action/:id', :controller => 'dispatch', :action => 'dispatch', :_page_action => 'show', :id => nil

  map.connect ':_context', :controller => 'dispatch', :action => 'dispatch', :_page => nil

  # i am not sure what this was for, but it breaks routes for committees. this
  # could be fixed by adding \+, but i am just commenting it out for now. -e
  # :_context => /[\w\.\@\s-]+/

end

