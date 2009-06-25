require "#{File.dirname(__FILE__)}/../../test_helper"

class Me::GroupsTest < ActionController::IntegrationTest
  def test_joining_network_when_indirect_member
    login 'dolphin'

    visit '/cnt'
    click_link 'join Network'
    assert_contain 'Leave Network'
  end
end
