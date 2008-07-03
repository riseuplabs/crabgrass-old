
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
require "#{RAILS_ROOT}/lib/extends_to_engines.rb"

#### ENUMERATIONS ##############

# levels of page access
ACCESS = {
 :admin => 1,
 :change => 2,
 :edit => 2, 
 :view => 3,
 :read => 3
}.freeze

# types of page flows
FLOW = {
 :membership => 1,
 :contacts => 2,
}.freeze

# do this early because environments/*.rb need it
require 'lib/crabgrass_config'

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
AVAILABLE_PAGE_CLASSES = Site.default.available_page_types.dup

Rails::Initializer.run do |config|
  config.load_paths += %w(associations discussion chat profile poll task).collect do |dir|
    "#{RAILS_ROOT}/app/models/#{dir}"
  end

  # gems that crabgrass depends on:
  # install with 'sudo rake gems:install'
#  config.gem 'RedCloth'
#  config.gem 'rmagick'
#  config.gem 'ruby-debug'
#  config.gem 'hpricot'

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer

  # currently, crabgrass stores an excessive amount of information in the session
  # in order to do smart breadcrumbs. These means we cannot use cookie based
  # sessions because they are too limited in size. If you want to switch to a different
  # storage container, you need to find a way to disable breadcrumbs as well. 
  config.action_controller.session_store = :p_store

  #
  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
#  config.action_controller.session = {
#    :session_key => '_crabgrass_session',
#    :secret      => #'9ce1ae3f9d26b56cf9fc7682635486898b3450a9e0116ea013a7a14dd24833cab5fafcd17f2c555f7663c0524a938e5ed6df2af8bf134d3959fc8ac3214fa8c7'
#  }
  
  # Make Active Record use UTC-base instead of local time
  config.time_zone = 'UTC'

  # allow plugins in mods/ and pages/
  config.plugin_paths << "#{RAILS_ROOT}/mods" << "#{RAILS_ROOT}/tools"

  # See Rails::Configuration for more options
end

# There appears to be something wrong with dirty tracking in rails.
# Lots of errors if this is enabled:
ActiveRecord::Base.partial_updates = false

# Store "Tool::Discussion" in database instead of just "Discussion"!
# ActiveRecord::Base.store_full_sti_class = true


#### DEBUGGING #####################

# this will cause classes in lib to be reloaded on each request in
# development mode. very useful if working on a source file in lib!
Dependencies.load_once_paths.delete("#{RAILS_ROOT}/lib")

# Make engines much less verbose!
if defined? Engines
  Engines.logger.level = ActiveSupport::BufferedLogger::Severity::INFO
  #Engines.logger.level = ActiveSupport::BufferedLogger::Severity::DEBUG
end

#### CUSTOM EXCEPTIONS #############

class PermissionDenied < Exception; end    # the user does not have permission to do that.
class ErrorMessage < Exception; end        # just show a message to the user.
class AssociationError < Exception; end    # thrown when an activerecord has made a bad association (for example, duplicate associations to the same object).

#### CORE LIBRARIES ################

require "#{RAILS_ROOT}/lib/extends_to_core.rb"
require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
require "#{RAILS_ROOT}/lib/fake_globalize.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
require "#{RAILS_ROOT}/lib/path_finder.rb"
require "#{RAILS_ROOT}/lib/page_class_proxy.rb"

#### TOOLS #########################

# run "rake update_page_classes" every time you add/remove a Page subclass:
#PAGE_CLASSES = PageClassProxy.load_page_classes

PAGES = PageClassRegistrar.proxies.dup.freeze

#PAGE_CLASSES.each do |pc|
#  PROXIES[pc.full_class_name] = pc
#end

#### ASSETS ########################

#Asset.file_storage = "/crypt/files"

#### USER INTERFACE HELPERS ########

FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist' if defined? FightTheMelons

if File.exists?('.svn')
  SVN_REVISION = (RAILS_ENV != 'test' && r = YAML.load(`svn info`)) ? r['Revision'] : nil
else
  SVN_REVISION = nil
end

