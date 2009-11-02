require 'rubygems'

begin
  require 'ruby-debug'
rescue LoadError => exc
  # no ruby debug installed
end

begin
  require 'redgreen' unless ARGV.include? "--no-color"
rescue LoadError => exc
  # no redgreen installed
end

# this can speed running a single test method from 11 seconds to 3
# see http://roman.flucti.com/a-test-server-for-rails-applications
begin
  require 'rails_test_serving'
  RailsTestServing.boot
rescue LoadError => exc
  # no rails-test-server gem
end

ENV["RAILS_ENV"] = "test"
$: << File.expand_path(File.dirname(__FILE__) + "/../")
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

require File.expand_path(File.dirname(__FILE__) + "/blueprints")

require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
end

require 'shoulda/rails'

module Tool; end



#
# put this at the top of your test, before the class def, to see
# the logs printed to stdout. useful for tracking what sql is called when.
# probably way too much information unless run with -n to limit the test.
# ie: ruby test/unit/page_test.rb -n test_destroy
#
def showlog
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

# This is a testable class that emulates an uploaded file
# Even though this is exactly like a ActionController::TestUploadedFile
# i can't get the tests to work unless we use this.
class MockFile
  attr_reader :path
  def initialize(path); @path = path; end
  def size; 1; end
  def original_filename; @path.split('/').last; end
  def read; File.open(@path) { |f| f.read }; end
  def rewind; end
end

class ParamHash < HashWithIndifferentAccess
end

def mailer_options
  {:site => Site.new(), :current_user => users(:blue), :host => 'localhost',
  :protocol => 'http://', :port => '3000', :page => @page}
end

class Test::Unit::TestCase
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

  # currently, for normal requests, we just redirect to the login page
  # when permission is denied. but this should be improved.
  def assert_permission_denied(message='missing "permission denied" message')
    if flash[:type]
      assert_equal 'error', flash[:type], message
      assert_equal 'Permission Denied', flash[:title], message
      assert_response :redirect
      assert_redirected_to :controller => :account, :action => :login
    else
      assert_select "div.title_box h1", "Permission Denied", message
    end
  end

  def assert_login_required(message='missing "login required" message')
    assert_equal 'info', flash[:type], message
    assert_equal 'Login Required', flash[:title], message
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def assert_error_message(regexp=nil)
    assert_equal 'error', flash[:type], flash.inspect
    if regexp
      assert flash[:text] =~ regexp, 'error message did not match %s. it was %s.'%[regexp.inspect, flash[:text]]
    end
  end

  def assert_message(regexp=nil)
    assert ['error','info','success'].include?(flash[:type]), 'no flash message (%s)'%flash.inspect
    if regexp
      str = flash[:text].any || flash[:title]
      assert(str =~ regexp, 'error message did not match %s. it was %s.'%[regexp.inspect, str])
    end
  end

  def assert_success_message(title_regexp = nil, text_regexp = nil)
    assert_equal 'success', flash[:type]
    if title_regexp
      assert flash[:title] =~ title_regexp, 'success message title did not match %s. it was %s.'%[title_regexp.inspect, flash[:text]]
    end
    if text_regexp
      assert flash[:text] =~ text_regexp, 'success message text did not match %s. it was %s.'%[text_regexp, flash[:text]]
    end
  end

  ##
  ## ASSET HELPERS
  ##

  def upload_data(file)
    type = 'image/png' if file =~ /\.png$/
    type = 'image/jpeg' if file =~ /\.jpg$/
    type = 'application/msword' if file =~ /\.doc$/
    type = 'application/octet-stream' if file =~ /\.bin$/
    fixture_file_upload('files/'+file, type)
  end

  def upload_avatar(file)
    MockFile.new(RAILS_ROOT + '/test/fixtures/files/' + file)
  end

  def read_file(file)
    File.read( RAILS_ROOT + '/test/fixtures/files/' + file )
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

  ##
  ## SPHINX HELPERS
  ##

  def print_sphinx_hints
    @@sphinx_hints_printed ||= false
    unless @@sphinx_hints_printed
# cg:update_page_terms
      puts "\nTo make thinking_sphinx tests not skip, try the following steps:
  rake RAILS_ENV=test db:test:prepare db:fixtures:load  # (should not be necessary, but always a good first step)
  rake RAILS_ENV=test ts:index ts:start                 # (needed to build the sphinx index and start searchd)
  rake test:functionals
See also doc/SPHINX"
      @@sphinx_hints_printed = true
    end

  end

  def sphinx_working?(test_name="")
    if !ThinkingSphinx.sphinx_running?
      print 'skip'
      print_sphinx_hints
      false
    else
      true
    end
  end

  def disable_site_testing
    Conf.disable_site_testing
    Site.current = Site.new
    @controller.disable_current_site if @controller
  end

  def enable_site_testing(site_name=nil)
    if site_name
      Conf.enable_site_testing(sites(site_name))
      Site.current = sites(site_name)
    else
      Conf.enable_site_testing()
      Site.current = Site.new
    end
    @controller.enable_current_site if @controller
  end

  # run the block with a site
  def with_site(site_name, site_attributes = true)
    return unless block_given?

    old_enabled_site_ids = Conf.enabled_site_ids
    old_site = Site.current

    # set the site to the new one
    enable_site_testing(site_name)
    # override site options
    unmodified_site_attributes = Site.current.attributes
    if site_attributes.respond_to? :each
      site_attributes.each {|attr, value| Site.current.send("#{attr}=", value)}
      updated_site_attributes = true
      Site.current.save!
    end

    # Run the block
    yield
  ensure
    # restore
    if updated_site_attributes
      Site.current.attributes = unmodified_site_attributes
      Site.current.save!
    end
    disable_site_testing
    Conf.enabled_site_ids = old_enabled_site_ids
    Site.current = old_site
  end

  # takes collections of sites and a block. runs all the tests defined in the block
  # for each site.
  # +sites+ is a hash, each key is a site name. values can be _true_, _false_ (don't test the site)
  # or a hash of site attributes to override
  #
  # Example:
  # with_site(:site1 => {:profiles => ['private']}, :site2 => true) {
  #   def test_something;
  #     assert_something
  #   end
  # }
  def self.repeat_with_sites(sites = {})
    return unless block_given?

    # yield will define some new methods, some of which are tests
    old_methods = self.instance_methods
    yield
    new_methods = self.instance_methods
    # methods defined in the yielded block that start with 'test'
    new_test_methods = (new_methods - old_methods).grep /^test/

    new_test_methods.each do |test_method_name|
      aliased_test_method_name = "do_#{test_method_name}".to_sym
      test_method_name = test_method_name.to_sym

      # alias do_test_something for test_something
      self.class_eval "alias :#{aliased_test_method_name} :#{test_method_name}"
      # delete test_something (so it's not get executed)
      self.class_eval "undef :#{test_method_name}"

      sites.keys.each do |site_name|
        site_attributes = sites[site_name]
        next unless site_attributes
        site_name = "nil" if site_name.nil?
        site_method_name = "#{test_method_name}_with_site_#{site_name}"

        define_method site_method_name do
          with_site(site_name, site_attributes) {send(aliased_test_method_name)}
        end
      end
    end

    # old_enabled_site_ids = Conf.enabled_site_ids
    # old_site = Site.current
    # # set the site to the new one
    # enable_site_testing(site)
    # yield
    # # restore
    # Conf.enabled_site_ids = old_enabled_site_ids
    # Site.current = old_site
  end

  def enable_unlimited_site_testing(site_name=nil)
    if block_given?
      enable_site_testing(site_name, false) do
        yield
      end
    else
      enable_site_testing(site_name, false)
    end
  end

  ##
  ## DEBUGGING HELPERS
  ##

  # prints out a readable version of the response. Useful when using the debugger
  def response_body
    puts @response.body.gsub(/<\/?[^>]*>/, "").split("\n").select{|str|str.strip.any?}.join("\n")
  end

  ##
  ## ROUTE HELPERS
  ##

  def url_for(options)
    url = ActionController::UrlRewriter.new(@request, nil)
    url.rewrite(options)
  end

  ##
  ## FIXTURE HELP
  ##

  # we use transactional fixtures for everything except page terms
  # page_terms is a different ttable type (MyISAM) which doesn't support transactions
  # this method will reload the original page terms from the fixture files
  def reset_page_terms_from_fixtures
    fixture_path = ActiveSupport::TestCase.fixture_path
    Fixtures.reset_cache
    Fixtures.create_fixtures(fixture_path, ["page_terms"])
  end

  ##
  ## MORE ASSERTS
  ##

  def assert_layout(layout)
    assert_equal layout, @response.layout
  end

  ##
  ## AUTHENTICATION
  ##
  def login_as(user)
    user = case user
      when Symbol then users(user)
      when User   then user
      else             nil
    end
    @controller.stubs(:current_user).returns(user)
    @request.session[:user] = user
  end

  # the normal acts_as_authenticated 'login_as' does not work for integration tests
  def login(user)
    post '/account/login', {:login => user.to_s, :password => user.to_s}
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
