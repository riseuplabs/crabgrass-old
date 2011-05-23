require "#{File.dirname(__FILE__)}/../../test_helper"

class Me::RequestsTest < ActionController::IntegrationTest

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
