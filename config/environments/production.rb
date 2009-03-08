# Settings specified here will take precedence over those in config/environment.rb

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
#config.action_controller.consider_all_requests_local = false

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

##
## SECURITY
##

# set cookies to 'secure'; prevent some kinds of session-stealing attacks
Crabgrass::Config.https_only = false

##
## CACHING
## 

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true
#config.cache_classes =false

config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
#config.action_controller.perform_caching             = false
#config.action_view.cache_template_loading            = false

# bundled_assets plugin:
# in production mode, compress css and js files and page cache the result
MAKE_ASSET_BUNDLES = true

# Use a different cache store in production
# config.cache_store = :mem_cache_store

##
## LOGGING
## 

# use syslog if available
begin
  require 'syslog_logger'
  #RAILS_DEFAULT_LOGGER = SyslogLogger.new
  config.logger = SyslogLogger.new
rescue LoadError => exc
  # i guess there is no syslog_logger
end

# the default log level for production should be to only log warnings. 
config.log_level = :warn
if defined? Engines
  Engines.logger = ActiveSupport::BufferedLogger.new(config.log_path)
  Engines.logger.level = Logger::WARN
end

#ANALYZABLE_PRODUCTION_LOG = "#{RAILS_ROOT}/log/production.log"
ANALYZABLE_PRODUCTION_LOG = "/var/log/rails.log"

##
## ASSETS
##

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

ASSET_PRIVATE_STORAGE = "#{RAILS_ROOT}/assets"
ASSET_PUBLIC_STORAGE  = "#{RAILS_ROOT}/public/assets"
KEYRING_STORAGE = "#{RAILS_ROOT}/assets/keyrings"

