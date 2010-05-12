require "#{File.dirname(__FILE__)}/../../test_helper"

class Groups::NavigationTest < ActionController::IntegrationTest
  def test_nonmembers_cannot_see_administration_tab 
    # network
    login 'red'
    visit '/fau'
    assert_not_contain I18n.t(:administration) 

    # group
    visit '/animals'
    assert_not_contain I18n.t(:administration)
  end

  def test_members_can_see_administration_tab 
    login 'red'
    visit '/rainbow'
    assert_contain I18n.t(:administration)

    login 'gerrard'
    visit '/fau'
    assert_contain I18n.t(:administration)
  end
end
