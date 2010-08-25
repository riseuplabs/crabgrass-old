require 'rubygems'

def try_to_load(name, &block)
  begin
    if block_given?
      yield block
    else
      require name
    end
  rescue LoadError => exc
    puts "Warning: could not load %s" % name
  end
end

##
## load the environment
##

ENV["RAILS_ENV"] = "test"
$: << File.expand_path(File.dirname(__FILE__) + "/../")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

##
## load gems useful for testing
##

try_to_load :mocha do
  gem 'mocha'
  require 'mocha'
end

try_to_load 'leftright'

try_to_load :blueprints do
  require File.expand_path(File.dirname(__FILE__) + "/cg_blueprints")
end

try_to_load 'webrat' do
  require 'webrat'
  Webrat.configure do |config|
    config.mode = :rails
  end
end

try_to_load 'shoulda/rails'

##
## load all the test helpers
##

Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

##
## misc.
##

include ActionController::Assertions::ResponseAssertions
ActionController::TestCase.send(:include, FunctionalTestHelper) unless ActionController::TestCase.included_modules.include?(FunctionalTestHelper)

class ActiveSupport::TestCase
  setup { Sham.reset }

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  ##########################################################################
  # Add more helper methods to be used by all tests here...

  include AuthenticatedTestHelper
  include AssetTestHelper
  include SphinxTestHelper
  include SiteTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include DebugTestHelper

  # make sure the associations are at least defined properly
  def check_associations(m)
    @m = m.new
    m.reflect_on_all_associations.each do |assoc|
      assert_nothing_raised("association '#{assoc.name}' caused an error") do
        @m.send(assoc.name)
      end
    end
    true
  end
end

# some special rules for integration tests
class ActionController::IntegrationTest
  # we load all fixtures because webrat integration test should see exactly
  # the same thing the user sees in development mode
  # using self.inherited to make sure
  # all fixtures are being loaded only if some integration tests are being defined
  def self.inherited(subclass)
    subclass.fixtures :all
  end
end
