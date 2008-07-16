# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
require "#{RAILS_ROOT}/lib/extends_to_engines.rb"

Dependencies.load_once_paths << "#{RAILS_ROOT}/lib"

# levels of page access
ACCESS = {:admin => 1, :change => 2, :edit => 2, :view => 3, :read => 3}.freeze

# types of page flows
FLOW = {:membership => 1, :contacts => 2, :deleted => 3}.freeze

# do this early because environments/*.rb need it
require 'lib/crabgrass/config'

# get list of mods to enable (before plugins are loaded)
MODS_ENABLED = File.read("#{RAILS_ROOT}/config/mods_enabled.list").split("\n").freeze
TOOLS_ENABLED = File.read("#{RAILS_ROOT}/config/tools_enabled.list").split("\n").freeze

require "#{RAILS_ROOT}/lib/site.rb"
Site.load_from_file("#{RAILS_ROOT}/config/sites.yml")

# legacy configurations that should now be removed and changed to 
# reference via @site in the code:
Crabgrass::Config.site_name     = Site.default.name
Crabgrass::Config.host          = Site.default.domain
Crabgrass::Config.email_sender  = Site.default.email_sender
Crabgrass::Config.secret        = Site.default.secret
SECTION_SIZE = Site.default.pagination_size

Rails::Initializer.run do |config|

  config.load_paths += %w(associations discussion chat profile poll task).collect do |dir|
    "#{RAILS_ROOT}/app/models/#{dir}"
  end

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer

  # currently, crabgrass stores an excessive amount of information in the session
  # in order to do smart breadcrumbs. These means we cannot use cookie based
  # sessions because they are too limited in size. If you want to switch to a different
  # storage container, you need to find a way to disable breadcrumbs as well. 
  config.action_controller.session_store = :p_store

  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # allow plugins in mods/ and pages/
  config.plugin_paths << "#{RAILS_ROOT}/mods" << "#{RAILS_ROOT}/tools"

  # Deliveries are disabled by default. Do NOT modify this section.
  # Define your email configuration in email.yml instead.
  # It will automatically turn deliveries on
  config.action_mailer.perform_deliveries = false

  # See Rails::Configuration for more options
end

# There appears to be something wrong with dirty tracking in rails.
# Lots of errors if this is enabled:
ActiveRecord::Base.partial_updates = false

# build an array of PageClassProxy objects
PAGES = PageClassRegistrar.proxies.dup.freeze

