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
    visit '/groups/rainbow/edit'
    # should save the fragment
    assert_contain I18n.t(:administration)

    # create a council
    login 'blue'
    visit '/groups/councils/new/rainbow'

    fill_in "Full Name", :with => "Indigo Council"
    fill_in "Link Name", :with => "indigo"

    click_button "Create"

    assert_contain 'Group was successfully created'

    # red, who is not a council member
    # should not see 'Send Invites' link anymore
    # if red can see them, then cache wasn't expired

    login 'red'
    visit '/rainbow'

    assert_contain 'Council'
    assert_not_contain I18n.t(:administration)

    # blue should see the right links too if cache was expired
    login 'blue'
    visit '/rainbow'

    assert_contain 'Council'
    assert_contain I18n.t(:administration)
  end
end
