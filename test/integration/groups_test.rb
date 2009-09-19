require File.dirname(__FILE__) + '/../test_helper'

class GroupsTest < ActionController::IntegrationTest
  def test_join_network_we_have_access_to
    login :penguin
    get '/fau'
    assert_select('a[href="/groups/memberships/join/fau"]') do
      assert_select 'a', 'Join Network'
    end

    assert_difference 'Membership.count' do
      post "/groups/memberships/join/fau"
    end
  end

  def test_change_group_membership_policy
    login 'blue'
    visit '/rainbow'
    click_link 'Edit Settings'
    click_link 'Permissions'

    check 'Allow Membership Requests'
    check 'Open Group'
    click_button 'Save'
    assert_contain 'Changes saved'

    login 'aaron'
    visit '/rainbow'

    click_link 'Join Group'
    assert_contain 'Leave Group'

    # disable open group. should change what users see
    login 'blue'
    visit '/rainbow'
    click_link 'Edit Settings'
    click_link 'Permissions'

    check 'Allow Membership Requests'
    uncheck 'Open Group'
    click_button 'Save'
    assert_contain 'Changes saved'

    login 'aaron'
    visit '/rainbow'
    click_link 'Leave Group'
    click_button 'Leave'

    click_link 'Request to Join Group'
    click_button 'Send Request'
    assert_contain 'Request to join has been sent'
  end

end
