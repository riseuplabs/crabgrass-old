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

  # clean out the data from the database with TRUNCATE
  AfterConfiguration do |config|
    require 'database_cleaner'
    DatabaseCleaner.clean_with :truncation
  end

  require File.expand_path(File.join(File.dirname(__FILE__), "paths"))
end
