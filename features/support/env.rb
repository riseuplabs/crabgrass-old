require 'rubygems'
require 'spork'

# this code is run by spork daemon if it's running and cucumber is started with --drb option
# otherwise this is loaded at the start of the cucumber process
Spork.prefork do
  # Sets up the Rails environment for Cucumber
  ENV["RAILS_ENV"] = "cucumber"
  require File.expand_path(File.dirname(__FILE__) + '/../../config/environment')
  require 'cucumber/rails/world'
  require 'cucumber'
  require 'cucumber/formatter/unicode'

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


