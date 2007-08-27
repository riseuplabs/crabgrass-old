
# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')


########################################################################
### BEGIN CUSTOM OPTIONS

SITE_NAME = 'riseup.net'
SECTION_SIZE = 29 # the default size for pagination sections

### END CUSTOM OPTIONS
########################################################################


# levels of page access
ACCESS = {
 :admin => '1',
 :change => '2',
 :edit => '2', 
 :view => '3',
 :read => '3'
}.freeze

# types of page flows
FLOW = {
 :membership => '1',
 :contacts => '2',
}.freeze


Rails::Initializer.run do |config|
  config.load_paths += %w(associations discussion chat).collect do |dir|
    "#{RAILS_ROOT}/app/models/#{dir}"
  end
  
  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  config.action_controller.session_store = :p_store
  
  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

#### SESSION HANDLING ##############

ActionController::Base.session_options[:session_expires] = 3.hours.from_now
if File.directory? '/dev/shm/'
  ActionController::Base.session_options[:tmpdir] = '/dev/shm/'
end
  
#### CUSTOM EXCEPTIONS #############

class PermissionDenied < Exception; end
class ErrorMessage < Exception; end

#### CORE LIBRARIES ################

require "#{RAILS_ROOT}/lib/extends_to_core.rb"
require "#{RAILS_ROOT}/lib/extends_to_active_record.rb"
require "#{RAILS_ROOT}/lib/extends_like_edge.rb"
require "#{RAILS_ROOT}/lib/greencloth/greencloth.rb"

#### TOOLS #########################

# pre-load the tools:
Dir.glob("#{RAILS_ROOT}/app/models/tool/*.rb").each do |toolfile|
  require toolfile
end
# a static array of tool classes:
TOOLS = Tool.constants.collect{|tool|Tool.const_get(tool)}.freeze

#### ASSETS ########################

#Asset.file_storage = "/crypt/files"

#### TIME ##########################

ENV['TZ'] = 'UTC' # for Time.now
DEFAULT_TZ = 'Pacific Time (US & Canada)'

# remove this when we upgrade to new rails:
require 'acts_like_date_or_time'

#### USER INTERFACE HELPERS ########

FightTheMelons::Helpers::FormMultipleSelectHelperConfiguration.outer_class = 'plainlist'

