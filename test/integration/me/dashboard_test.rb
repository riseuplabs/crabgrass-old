require "#{File.dirname(__FILE__)}/../../test_helper"

class Me::DashboardTest < ActionController::IntegrationTest

  def test_set_status
    login 'orange'

    visit '/me/pages'
    # identify the field by id attribute
    fill_in 'say_text', :with => 'Staying orange here'
    click_button 'Say'

    #assert_contain 'My Dashboard'
    # select the text input
    #assert_have_selector "#say_text", :content => 'Staying orange here'
    # check text with regular expression
    assert_contain %r{Staying orange here}
  end

  def test_joining_network_updates_requests
    login 'aaron'
    visit '/cnt'
    click_link I18n.t(:request_join_group_link, :group_type => 'Network')
    click_button 'Send Request'
    assert_contain 'Request to join has been sent'

    login 'blue'
    visit '/me/requests'
    assert_contain 'Aaron! requested to join Confederación Nacional del Trabajo'

    request_id = Request.last.id

    check field_with_id("request_checkbox_#{request_id}")
    fill_in "mark_as", :with => 'approve'
    submit_form("mark_form")


    visit '/me/requests'
    assert_not_contain 'Aaron! requested to join Confederación Nacional del Trabajo'

    login 'aaron'
    visit '/cnt'

    assert_not_contain 'Request to Join Network'
  end

end
