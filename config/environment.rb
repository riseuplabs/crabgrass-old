
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.0' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')

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
require 'crabgrass_config'

########################################################################
### BEGIN CUSTOM OPTIONS

Crabgrass::Config.site_name         = 'riseup.net' 
Crabgrass::Config.host  = 'we.riseup.net'
Crabgrass::Config.email_sender      = 'crabgrass-system@riseup.net'
Crabgrass::Config.secret = 'd24833cab5fafcd17f2c555f7663c0524a938e5ed6df2af8bf134d3959fc8ac3214fa8c7'

SECTION_SIZE = 29 # the default size for pagination sections

AVAILABLE_PAGE_CLASSES = %w[
  Message Discussion TextDoc RateMany RankedVote TaskList Asset
]

### END CUSTOM OPTIONS
########################################################################

CORE_PLUGINS    = %w[acts_as_list acts_as_tree classic_pagination will_paginate browser_filters]
UI_PLUGINS      = %w[calendar_date_select nested_layouts textile_editor_helper multiple_select validates_as_email]
GRAPHIC_PLUGINS = %w[ruby-svg-1.0.3 attachment_fu flex_image]
TESTING_PLUGINS = %w[rspec_on_rails webrat mocha rspec spider_test]
SKETCHY_PLUGINS = %w[acts_as_versioned acts_as_rateable thinking-sphinx]

ALL_PLUGINS = CORE_PLUGINS + UI_PLUGINS + GRAPHIC_PLUGINS + TESTING_PLUGINS + SKETCHY_PLUGINS

Rails::Initializer.run do |config|
  config.load_paths += %w(associations discussion chat profile task poll).collect do |dir|
    "#{RAILS_ROOT}/app/models/#{dir}"
  end
 
#  config.plugins = ALL_PLUGINS - ['will_paginate']

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

  # See Rails::Configuration for more options
end

# There appears to be something wrong with dirty tracking in rails.
# Lots of errors if this is enabled:
ActiveRecord::Base.partial_updates = false

ActiveRecord::Base.store_full_sti_class = true

#### CUSTOM EXCEPTIONS #############

class PermissionDenied < Exception; end    # the user does not have permission to do that.
class ErrorMessage < Exception; end        # just show a message to the user.
class AssociationError < Exception; end    # thrown when an activerecord has made a bad association (for example, duplicate associations to the same object).

#### CORE LIBRARIES ################

require "#{RAILS_ROOT}/lib/extends_to_core.rb"
require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
require "#{RAILS_ROOT}/lib/fake_globalize.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"
require "#{RAILS_ROOT}/lib/misc.rb"
require "#{RAILS_ROOT}/lib/path_finder.rb"

#### TOOLS #########################

# pre-load the tools:
Dir.glob("#{RAILS_ROOT}/app/models/tool/*.rb").each do |toolfile|
  require toolfile
end
# a static array of tool classes:
TOOLS = Tool.constants.collect{|tool|Tool.const_get(tool)}.freeze

AVAILABLE_PAGE_CLASSES.collect!{|i|Tool.const_get(i)}.freeze

#### ASSETS ########################

#Asset.file_storage = "/crypt/files"

#### USER INTERFACE HELPERS ########


FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist' if defined? FightTheMelons

SVN_REVISION = (RAILS_ENV != 'test' && r = YAML.load(`svn info`)) ? r['Revision'] : nil
 

