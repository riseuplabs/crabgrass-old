require "#{File.dirname(__FILE__)}/../test_helper"

class CachingTest < ActionController::IntegrationTest
  def setup
    Rails.cache.clear
    ActionController::Base.perform_caching = true
  end

  def teardown
    ActionController::Base.perform_caching = false
    Rails.cache.clear
  end

  def test_joining_group_council_updates_group_info_box
    login 'red'
    visit '/rainbow'
    # should save the fragment
    assert_contain "Send Invites"
    assert_contain "View Requests"

    # create a council
    login 'blue'
    visit '/groups/councils/new/rainbow'

    fill_in "Full Name", :with => "Indigo Council"
    fill_in "Link Name", :with => "indigo"

    click_button "Create"

    assert_contain 'Group Created'

    # red, who is not a council member
    # should not see 'Send Invites' link anymore
    # if red can see them, then cache wasn't expired

    login 'red'
    visit '/rainbow'

    assert_contain 'Indigo Council'
    assert_not_contain "Send Invites"
    assert_not_contain "View Requests"

    # blue should see the right links too if cache was expired
    login 'blue'
    visit '/rainbow'

    assert_contain 'Indigo Council'
    assert_contain "Send Invites"
    assert_contain "View Requests"
  end
end