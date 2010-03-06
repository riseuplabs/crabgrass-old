require "#{File.dirname(__FILE__)}/../test_helper"

class SiteAdminTest < ActionController::IntegrationTest

  def setup
    enable_site_testing
  end

  def teardown
    disable_site_testing
  end

  def test_do_not_show_announcements
    login 'blue'
    visit '/admin'

    assert_not_contain I18n.t(:announcements) 
  end

end
