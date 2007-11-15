unless defined? HAS_LOADED_ENVIRONMENT
	HAS_LOADED_ENVIRONMENT = 1
  require File.join(File.dirname(__FILE__), 'boot')

  Rails::Initializer.run do |config|
    config.frameworks -= [ :action_web_service, :action_mailer ]
  end

  RAILS_DEFAULT_LOGGER.info "Rails version: #{Rails::VERSION}"
end
