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
require "#{RAILS_ROOT}/lib/extension/zip.rb"

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

  config.load_paths += %w(activity assets associations discussion chat observers profile poll task tracking requests mailers).collect{|dir|"#{RAILS_ROOT}/app/models/#{dir}"}
  config.load_paths << "#{RAILS_ROOT}/app/permissions"
  config.load_paths << "#{RAILS_ROOT}/app/sweepers"

  Engines.mix_code_from(:permissions)

  # this is required because we have a mysql specific fulltext index.
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  config.active_record.observers = :user_observer, :membership_observer,
    :group_observer, :relationship_observer, :post_observer, :page_tracking_observer

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
  config.gem 'riseuplabs-greencloth', :lib => 'greencloth'
  config.gem 'riseuplabs-undress', :lib => 'undress/greencloth'
  config.gem 'riseuplabs-uglify_html', :lib => 'uglify_html'
  config.gem 'faker', :lib => 'faker', :version => '>=0.3.1'
  #config.gem 'rmagick' unless system('dpkg -l librmagick-ruby1.8 2>/dev/null 1>/dev/null')
  #config.gem 'redcloth', :version => '>= 4.0.0'
  #config.frameworks += [ :action_web_service]
  #config.action_web_service = Rails::OrderedOptions.new
  #config.load_paths += %W( #{RAILS_ROOT}/vendor/plugins/actionwebservice/lib )
  #config.load_paths += %W( #{RAILS_ROOT}/mods/undp_sso/app/apis )

  # see http://ruby-doc.org/stdlib/libdoc/erb/rdoc/classes/ERB.html
  # for information on how trim_mode works.
  config.action_view.erb_trim_mode = '%-'

  # See Rails::Configuration for more options

  # we want handle sass templates ourselves
  # so we must not load the 'plugins/rails.rb' part of Sass
  module Sass
    RAILS_LOADED = true
  end

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

# build a hash of PageClassProxy objects {'TaskListPage' => <TaskListPageProxy>}
PAGES = PageClassRegistrar.proxies.dup.freeze
Conf.available_page_types = PAGES.keys if Conf.available_page_types.empty?


