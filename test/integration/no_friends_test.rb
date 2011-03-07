require "#{File.dirname(__FILE__)}/../test_helper"

class NoFriendsTest < ActionController::IntegrationTest

  def test_do_not_show_my_friends_tab
    login '/penguin'
    visit '/people/directory'
    assert_not_contain 'My friends' 
    assert_not_contain 'Social Activity'
    visit '/me/pages'
    assert_not_contain I18n.t(:my_contacts)

    login 'blue'
    visit '/me/pages'
    assert_contain I18n.t(:my_contacts)
    assert_contain 'Social Activity'
    visit '/people/directory'
    assert_contain 'My friends'
  end

end
