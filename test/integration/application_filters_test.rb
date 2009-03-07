require "#{File.dirname(__FILE__)}/../test_helper"

class ApplicationFiltersTest < ActionController::IntegrationTest
  fixtures :groups, :sites, :users

  def setup
    @hosts = ["localhost", "test.host"]
  end

  def test_set_site_from_host
    # assert sets the correct site
    @hosts.each do |hostname|
      host! hostname
      get '/'
      assert_equal hostname, Site.current.domain, "application controller should set the correct 'Site.current'"
    end

    host! "fakekyfake.host"
    get '/'
    assert_equal 'localhost', Site.current.domain, "application controller should fallback to default site for 'Site.current'"
  end
end