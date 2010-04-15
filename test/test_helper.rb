
require 'rubygems'

gem 'mocha'
require 'mocha'

begin
  require 'leftright'
rescue LoadError => exc
  # no leftright installed
end


# load the environment
ENV["RAILS_ENV"] = "test"
$: << File.expand_path(File.dirname(__FILE__) + "/../")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

# test_help.rb from rails
# loads test::unit and rails specific test classes like ActionController::IntegrationTest
require 'test_help'

require File.expand_path(File.dirname(__FILE__) + "/blueprints")

require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
end

require 'shoulda/rails'


# require all helpers
Dir[File.dirname(__FILE__) + '/helpers/*.rb'].each {|file| require file }

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
  include FunctionalTestHelper
  include AssetTestHelper
  include SphinxTestHelper
  include SiteTestHelper
  include LoginTestHelper
  include FixtureTestHelper
  include DebugTestHelper
  include SkipTestHelper

  # make sure the associations are at least defined properly
  def check_associations(m)
    @m = m.new
    m.reflect_on_all_associations.each do |assoc|
      assert_nothing_raised("#{assoc.name} caused an error") do
        @m.send(assoc.name, true)
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
