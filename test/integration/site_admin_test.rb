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
    with_site('local') do
      visit '/me/edit'
      assert_contain 'Public Profile'
    end
    with_site('local', {:profiles => ['private']}) do
      visit '/me/edit'
      assert_not_contain 'Public Profile'
    end
  end

  def test_disabled_profile_fields
    login 'blue'
    with_site('local', {:profile_fields => ['basic', 'websites']}) do 
      visit '/profile/edit/private'
      assert_not_contain I18n.t(:descriptions)
    end
  end

  def test_all_profiles_visible
    login 'blue'
    with_site('local') do
      visit '/profile/edit/private'
      assert_contain I18n.t(:profile_option_may_see)
      visit '/people/directory'
      assert_contain 'My friends'
      assert_contain 'My Peers'
      visit '/groups/directory'
      assert_contain 'My Groups'
      login 'penguin'
      visit '/yellow'
      assert_contain I18n.t(:request_friend_link)
    end
    with_site('local', {:all_profiles_visible => 1}) do 
      visit '/profile/edit/private'
      assert_contain I18n.t(:profile_option_may_see_groups)
      assert_not_contain I18n.t(:profile_option_may_see)
      visit '/people/directory'
      assert_contain 'All People'
      assert_not_contain 'My Friends'
      assert_not_contain 'My Peers'
      visit '/groups/directory'
      assert_contain 'My Groups'
      login 'penguin'
      visit '/yellow'
      assert_not_contain I18n.t(:request_friend_link)
    end
  end

end
