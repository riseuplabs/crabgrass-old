# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.2'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

PAGE_TYPES = %w(discussion poll rate_many event request wiki).freeze
SITE_NAME = 'riseup.net'

# levels of page access
ACCESS_ADMIN = '1'
ACCESS_CHANGE = '2'
ACCESS_VIEW = '3'

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %w(associations discussion).collect{|dir| "#{RAILS_ROOT}/app/models/#{dir}"}
  
  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Include your application configuration below

class InsufficientPermission < Exception; end

require "#{RAILS_ROOT}/lib/extends_to_core.rb"

# pre load the tool classes
Dir.glob("#{RAILS_ROOT}/app/models/tool/*.rb").each do |toolfile|
  #require "#{RAILS_ROOT}/app/models/tool/#{}"
  require toolfile
end
# static array of tool *classes*
TOOLS = Tool.constants.collect{|tool|Tool.const_get(tool)}.freeze

# pre load the actions (otherwise serialization won't work)
#Dir.glob("#{RAILS_ROOT}/app/models/actions/*.rb").each do |f|
#  require f
#end

