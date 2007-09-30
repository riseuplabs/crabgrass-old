ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

class Test::Unit::TestCase

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
  
=begin
  def assert_login_required(method, url)
    if method == :get
      get action, url
      assert_redirect_to {:controller => 'account', :action => 'login'}, "get %s must require a login" % url.inspect
    elsif method = :post
      post action, url
      assert_redirect_to {:controller => 'account', :action => 'login'}, "post %s must require a login" % url.inspect
    end
  end    

  def assert_login_not_required(method, url)
    if method == :get
      get action, url
      assert_response :success, {:controller => 'account', :action => 'login'}, "get %s must require a login" % url.inspect
    elsif method = :post
      post action, url
      assert_redirect_to {:controller => 'account', :action => 'login'}, "post %s must require a login" % url.inspect
    end
  end    
=end

end
