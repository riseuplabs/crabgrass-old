# Sets up the Rails environment for Cucumber
ENV["RAILS_ENV"] ||= "cucumber"
require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
require 'cucumber/rails/world'

# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'

# Comment out the next line if you don't want transactions to
# open/roll back around each scenario
Cucumber::Rails.use_transactional_fixtures

# Comment out the next line if you want Rails' own error handling
# (e.g. rescue_action_in_public / rescue_responses / rescue_from)
Cucumber::Rails.bypass_rescue

require 'webrat/rails'
require 'cucumber/webrat/element_locator' # Lets you do table.diff!(element_at('#my_table_or_dl_or_ul_or_ol').to_table)

Webrat.configure do |config|
  config.mode = :rails
end
require 'rubygems'
require 'spork'

# this code is run by spork daemon if it's running and cucumber is started with --drb option
# otherwise this is loaded at the start of the cucumber process
Spork.prefork do
  # Sets up the Rails environment for Cucumber
  ENV["RAILS_ENV"] = "cucumber"
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')

  require 'cucumber/formatter/unicode'
  require 'cucumber/rails/world'
  require 'cucumber/rails/active_record'
  require 'cucumber/web/tableish'

  require 'pickle/world'
  Pickle.configure do |config|
    config.adapters = [:machinist]
    config.map 'I', 'myself', 'me', 'my', :to => 'user: "me"'
  end

  require 'pickle/path/world'
end


# This code will be run each time you start cucumber.
Spork.each_run do
  ActionController::Base.allow_rescue = true

  require 'cucumber/rails/world'
  require 'test/blueprints.rb'
  require 'lib/crabgrass/navigation.rb'

  Before do
    @host = "test.host"

    # set rails host
    host! @host

    # make a site for this host and enable site testing
    @site = Site.make(:domain => @host)
    Conf.enable_site_testing

    Sham.reset
  end

  # clean out the data from the database with TRUNCATE
  AfterConfiguration do |config|
    require 'database_cleaner'
    DatabaseCleaner.clean_with :truncation
    DatabaseCleaner.strategy = :truncation
  end

  require File.expand_path(File.join(File.dirname(__FILE__), "paths"))
  require File.expand_path(File.join(File.dirname(__FILE__), "scopes"))

  def disable_site_testing
    Conf.disable_site_testing
    Site.current = Site.new
    @controller.disable_current_site if @controller
  end

  def enable_site_testing(site_name=nil)
    if site=Site.find_by_name(site_name)
      Conf.enable_site_testing(site)
      Site.current = site
    else
      Conf.enable_site_testing()
      Site.current = Site.new
    end
    @controller.enable_current_site if @controller
  end

  After { disable_site_testing }

end


>>>>>>> 0.5.1.1:features/support/env.rb
