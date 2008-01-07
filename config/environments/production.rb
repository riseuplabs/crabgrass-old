# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# do not log passwords to the log file.
config.log_level = :warn

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors if you bad email addresses should just be ignored
# config.action_mailer.raise_delivery_errors = false

begin
  require 'syslog_logger'
  RAILS_DEFAULT_LOGGER = SyslogLogger.new
rescue LoadError => exc
  # i guess there is no syslog_logger
end

#ANALYZABLE_PRODUCTION_LOG = "#{RAILS_ROOT}/log/production.log"
ANALYZABLE_PRODUCTION_LOG = "/var/log/rails.log"

# bundled_assets plugin:
# in production mode, compress css and js files and page cache the result
MAKE_ASSET_BUNDLES = true

# set cookies to 'secure'; prevent some kinds of session-stealing attacks
Crabgrass::Config.https_only = true

