#
# THINGS TO CONFIGURE
# 
# Hopefully, nothing here needs to be changed. But you should change stuff in:
# 
#   * config/database.yml
#   * config/sites.yml
#   * config/email.yml
#
# RAILS INITIALIZATION PROCESS:
#
# (1) framework
# (2) config block
# (3) environment
# (4) plugins
# (5) initializers
# (6) application
# (7) finally
#

###
### (1) FRAMEWORK
###

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
require "#{RAILS_ROOT}/lib/extension/engines.rb"
require "#{RAILS_ROOT}/lib/crabgrass/boot.rb"
require "#{RAILS_ROOT}/lib/zip/zip.rb"

# path in which zipped galleries (for download) will be stored.
GALLERY_ZIP_PATH = "#{RAILS_ROOT}/public/gallery_download"
unless File.exists?(GALLERY_ZIP_PATH)
  Dir.mkdir(GALLERY_ZIP_PATH)
end

# possible in plugin?
#class Rails::Configuration
#  attr_accessor :action_web_service
#end

Rails::Initializer.run do |config|
  ###
  ### (2) CONFIG BLOCK
  ###

  config.load_paths += %w(activity assets associations discussion chat observers profile poll task requests).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}

  # this is required because we have a mysql specific fulltext index.
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :contact_observer, :message_page_observer #, :user_relation_observer

  # currently, crabgrass stores an excessive amount of information in the session
  # in order to do smart breadcrumbs. These means we cannot use cookie based
  # sessions because they are too limited in size. If you want to switch to a different
  # storage container, you need to disable breadcrumbs or store them someplace else,
  # like an in-memory temporary table. 
  config.action_controller.session_store = :p_store

  # store fragments on disk, we might have a lot of them.
  config.action_controller.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # allow plugins in mods/ and pages/
  config.plugin_paths << "#{RAILS_ROOT}/mods" << "#{RAILS_ROOT}/tools"
 
  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on

  config.action_mailer.perform_deliveries = false

  # the absolutely required gems
  config.gem 'rmagick' unless system('dpkg -l librmagick-ruby1.8 2>/dev/null 1>/dev/null')
  #config.gem 'redcloth', :version => '>= 4.0.0'

  #config.frameworks += [ :action_web_service]
  #config.action_web_service = Rails::OrderedOptions.new
  #config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/actionwebservice/lib )
  #config.load_paths += %W( #{RAILS_ROOT}/mods/undp_sso/app/apis )

  # See Rails::Configuration for more options

  ###
  ### (3) ENVIRONMENT 
  ###     config/environments/development.rb
  ###

  ###
  ### (4) PLUGINS
  ###     Plugins are loading in alphanumerical order across all
  ###     all these directories:  
  ###       vendors/plugins/*/init.rb
  ###       mods/*/init.rb
  ###       tools/*/init.rb
  ###     If you want to control the load order, change their names!
  ###

  ###
  ### (5) INITIALIZERS
  ###     config/initializers/*.rb
  ###

  ###
  ### (6) APPLICATION
  ###     app/*/*.rb
  ###

end

###
### (7) FINALLY
###
#require 'actionwebservice'
#require RAILS_ROOT+'/vendor/plugins/actionwebservice/lib/actionwebservice'

# There appears to be something wrong with dirty tracking in rails.
# Lots of errors if this is enabled:
ActiveRecord::Base.partial_updates = false

# build an array of PageClassProxy objects
PAGES = PageClassRegistrar.proxies.dup.freeze

