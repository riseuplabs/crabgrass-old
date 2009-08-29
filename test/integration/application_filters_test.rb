require "#{File.dirname(__FILE__)}/../test_helper"

class ApplicationFiltersTest < ActionController::IntegrationTest
  fixtures :groups, :sites, :users

  def setup
    @hosts = ["localhost", "test.host"]
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_set_site_from_host
    # assert sets the correct site
    @hosts.each do |hostname|
      host! hostname
      get '/'
      assert_equal hostname, @controller.current_site.domain, "application controller should set the correct 'current_site'"
    end

    host! "fakekyfake.host"
    get '/'
    assert_equal 'localhost', @controller.current_site.domain, "application controller should fallback to default site for 'current_site'"
  end

  def test_unverified_user_gets_redirected
    gerrard = users(:gerrard)
    gerrard.unverified = true
    gerrard.save!

    login 'gerrard'
    get '/me/dashboard'

    assert_redirected_to :controller => 'account', :action => 'unverified'
  end

end
