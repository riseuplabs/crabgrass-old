# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true

# set this to true to play with view caching:
config.action_controller.perform_caching             = false

# Do care if the mailer can't send
config.action_mailer.raise_delivery_errors = true

# this will cause classes in lib to be reloaded on each request in
# development mode. very useful if working on a source file in lib!
Dependencies.load_once_paths.delete("#{RAILS_ROOT}/lib")


