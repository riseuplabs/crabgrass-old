ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/../lib/enhanced_migrations")
require 'test/unit'
require 'test_help'
require File.dirname(__FILE__) + '/capture_stdout'

Dir[File.dirname(__FILE__) + '/../tasks/*.rake'].each { |rake| load rake }

class Test::Unit::TestCase
  self.use_transactional_fixtures = true if self.respond_to?(:use_transactional_fixtures)
  self.use_instantiated_fixtures  = false if self.respond_to?(:use_instantiated_fixtures)
end
