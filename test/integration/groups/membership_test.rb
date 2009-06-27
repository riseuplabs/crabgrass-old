require "#{File.dirname(__FILE__)}/../../test_helper"

class Groups::MembershipTest < ActionController::IntegrationTest
  def test_joining_network_when_indirect_member
    login 'dolphin'

    visit '/cnt'
    click_link 'join Network'
    assert_contain 'Leave Network'
  end

  def test_joining_open_membership_group
    login 'red'

    visit '/the-true-levellers'
    click_link 'Join Group'

    assert_contain 'Leave Group'

    click_link 'Leave Group'
    click_button 'Leave'

    assert_contain 'Join Group'
  end
end
