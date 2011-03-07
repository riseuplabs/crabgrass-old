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

# still working on this test
#  def test_expanded_group_wikis
#    login 'blue'
#    with_site(:local, {:show_expanded_group_wikis => 1}) do
#      visit '/group_with_long_wiki'
#      assert_contain 'this is the end of the really long wiki'
#      assert_contain 'close'
#    end
#
#    with_site(:local) do
#      visit '/group_with_long_wiki'
#      asssert_not_contain 'this is the end of the really long wiki'
#      assert_contain 'more'
#    end
#
#  end

  def test_disabled_public_profile
    login 'blue'
    with_site('connectingclassrooms', {:profiles => ['private']}) do
      visit '/me/edit'
      assert_not_contain 'Public Profile'
    end
  end

  def test_all_profiles_visible
    login 'blue'
    with_site('connectingclassrooms') do 
      visit '/profile/edit/private'
      assert_not_contain I18n.t(:profile_option_may_see)
    end
  end

end
