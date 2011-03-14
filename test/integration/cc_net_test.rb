require "#{File.dirname(__FILE__)}/../test_helper"

class CcNetTest < ActionController::IntegrationTest

  def test_not_show_friends_link
    login 'penguin'
    visit '/yellow'
    assert_not_contain I18n.t(:request_friend_link)
    assert_not_contain I18n.t(:remove_friend_link)
  end

  def test_remove_friend_things_from_profile_permissions
    login 'penguin'
    visit '/profile/edit/private'
    assert_not_contain I18n.t(:profile_option_may_see_contacts)
    assert_not_contain I18n.t(:profile_option_may_request_contact)
  end

  def test_my_peers_does_not_mention_friends
    # if this test fails, it is likely because the translation changed for the my peers tab description
    login 'blue'
    visit '/people/directory/peers'
    assert_not_contain "A list of your friends and all the people in your groups and networks."    
    assert_contain "A list of all the people in your groups and networks."
  end

end
