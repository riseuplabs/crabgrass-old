#
# THINGS TO CONFIGURE
#
# There are three files that need to be configured for crabgrass:
#
#   * config/secret.txt  (rake make_a_secret)
#   * config/database.yml
#   * config/crabgrass.[production|development|test].yml
#
# Hopefully, nothing in environment.rb will need to be changed.
#
# There are many levels of possible defaults for configuration options.
# In order of precedence, crabgrass will search:
#
#   (1) the current site
#   (2) the default site (if a site has default == true)
#   (3) options configured in the file config/crabgrass.*.yml
#   (4) last-stop hardcoded defaults in lib/crabgrass/conf.rb
#
# RAILS INITIALIZATION PROCESS:
#
#   1. framework
#   2. config block
#   3. environment
#   4. plugins
#   5. gems
#   6. initializers
#   7. view paths
#   8. application classes
#
# run rails with INFO=0 to see when these are loaded.
#
# for much more detail, see http://railsguts.com/initialization.html
#

require "#{File.dirname(__FILE__)}/../lib/crabgrass/info.rb"

###
### FRAMEWORK
###

info "LOAD FRAMEWORK"

# Use any Rails in the 2.3.x series 
RAILS_GEM_VERSION = '~> 2.3.0'

# Bootstrap the Rails environment
require File.join(File.dirname(__FILE__), 'boot')

# Bootstrap crabgrass specific initializations
require "#{RAILS_ROOT}/lib/crabgrass/boot.rb"

Crabgrass::Initializer.run do |config|
  ###
  ### CONFIG BLOCK
  ###

  info "LOAD CONFIG BLOCK"

  config.load_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}
  config.load_paths << "#{RAILS_ROOT}/app/permissions"
  config.load_paths << "#{RAILS_ROOT}/app/sweepers"
  config.load_paths << "#{RAILS_ROOT}/app/helpers/classes"

  # this is required because we have a mysql specific fulltext index.
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :relationship_observer, :post_observer, :page_tracking_observer,
    :request_to_destroy_our_group_observer

  config.action_controller.session_store = :cookie_store #:mem_cache_store # :p_store

  # store fragments on disk, we might have a lot of them.
  config.action_controller.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # allow plugins in mods/ and tools/
  config.plugin_paths << "#{RAILS_ROOT}/mods" << "#{RAILS_ROOT}/tools"

  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  ##
  ## GEMS
  ## see environments/test.rb for testing specific gems
  ##

  # frozen: the absolutely required gems
  config.gem 'riseuplabs-greencloth', :lib => 'greencloth'
  config.gem 'riseuplabs-undress', :lib => 'undress/greencloth'
  config.gem 'riseuplabs-uglify_html', :lib => 'uglify_html'
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '1.3.19'
  config.gem 'will_paginate'

  # frozen: required when modifying themes
  config.gem 'compass'
  config.gem 'compass-susy-plugin', :lib => 'susy'

  # required, but not included with crabgrass:
  config.gem 'haml'
  config.gem 'RedCloth'

  config.action_controller.session = {
    :key => '_crabgrass_session', :secret => Conf.secret
  }

  # See Rails::Configuration for more options

end

#
# subsequent loading:
#
#   ENVIRONMENT
#     eg config/environments/development.rb
#
#   GEMS
#     all config.gem gems
#
#   PLUGINS
#     Plugins are loading in alphanumerical order across all
#     all these directories:
#       vendors/plugins/*/init.rb
#       mods/*/init.rb
#       tools/*/init.rb
#     If you want to control the load order, change config.plugins
#
#   INITIALIZERS
#     config/initializers/*.rb
#
#   APPLICATION CLASSES
#     app/*/*.rb
#


# There appears to be something wrong with dirty tracking in rails.
# Lots of errors if this is enabled:
# TODO: enable this
ActiveRecord::Base.partial_updates = false

# build a hash of PageClassProxy objects {'TaskListPage' => <TaskListPageProxy>}
PAGES = PageClassRegistrar.proxies.dup.freeze
Conf.available_page_types = PAGES.keys if Conf.available_page_types.empty?

Haml::Template.options[:format] = :html5


##
## STUFF THAT HAS BEEN REMOVED FROM THIS FILE
## 

  #Engines.mix_code_from(:permissions)
  #Engines.disable_code_mixing = false

  # currently, crabgrass stores an excessive amount of information in the session
  # in order to do smart breadcrumbs. These means we cannot use cookie based
  # sessions because they are too limited in size. If you want to switch to a different
  # storage container, you need to disable breadcrumbs or store them someplace else,
  # like an in-memory temporary table.
  #
  # I changed this because it doesn't work with rails 2.3
  # FIXME: figure out if it makes sense this way.
  # config.action_controller.session_store = :cookie_store #:mem_cache_store # :p_store

# may be useful to determine plugin order, instead of stupid renaming:
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ] 

  # moved to environment/test.rb
  #unless ['development', 'production'].include? RAILS_ENV
  #  config.gem 'cucumber'
  #  config.gem 'mocha'
  #end

  # see http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html
  # for information on how trim_mode works.
  #
  # FIXME: this is broken in Rails 2.3. (https://rails.lighthouseapp.com/projects/8994/tickets/2553-actionviewtemplatehandlerserberb_trim_mode-broken)
  # still broken in 2.3.8
  #config.action_view.erb_trim_mode = '%-'

  # we want handle sass templates ourselves
  # so we must not load the 'plugins/rails.rb' part of Sass
  #module Sass
    # this was commented to get compass working
    # TODO: check for some problem with this
  #  RAILS_LOADED = true
  #end

  # to keep something from getting unloaded by rails:
  #config.after_initialize do
  #  require 'feature_x'  
  #  FeatureX.set_some_persistent_attribute :foo => :bar
  #end

#require 'actionwebservice'
#require RAILS_ROOT+'/vendor/plugins/actionwebservice/lib/actionwebservice'

