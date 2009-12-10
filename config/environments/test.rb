# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!

# regenerate customized css every request
# see docs/THEMING
Conf.always_renegerate_themed_stylesheet = true

config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.perform_deliveries = true
config.action_mailer.delivery_method = :test

### GEMS
config.gem 'webrat',      :lib => false,        :version => '>=0.5.3' unless File.directory?(File.join(Rails.root, 'vendor/plugins/webrat'))


ASSET_PRIVATE_STORAGE = "#{RAILS_ROOT}/tmp/private_assets"
ASSET_PUBLIC_STORAGE  = "#{RAILS_ROOT}/tmp/public_assets"

MIN_PASSWORD_STRENGTH = 0

# however, rails engines are way too verbose, so set engines logging to info:
if defined? Engines
  Engines.logger = ActiveSupport::BufferedLogger.new(config.log_path)
  Engines.logger.level = Logger::INFO
end

##
## INTERESTING STUFF FOR DEBUGGING
##

if false
  #
  # if enabled, this will print out when each callback gets called.
  #
  class ActiveSupport::Callbacks::Callback
    @@last_kind = nil

    @@debug_callbacks = [:before_validation, :before_validation_on_create, :after_validation,
   :after_validation_on_create, :before_save, :before_create, :after_create, :after_save]

    @@active_record_callbacks = nil

    def call_with_debug(*args, &block)
      @@active_record_callbacks ||= Hash[@@debug_callbacks.collect do |callback|
        methods = ActiveRecord::Base.send("#{callback}_callback_chain").collect{|cb|cb.method}
        [callback, methods]
      end]

      if should_run_callback?(*args) and method.is_a?(Symbol) and @@debug_callbacks.include?(kind) and !@@active_record_callbacks[kind].include?(method)
        if @@last_kind != kind
          puts "++++ #{kind} #{'+'*60}"
        end
        puts "---- #{method} ----"
        @@last_kind = kind
      end
      call_without_debug(*args, &block)
    end
    alias_method_chain :call, :debug
  end

  # this is most useful in combination with ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end
