require "#{File.dirname(__FILE__)}/../../test_helper"

class Me::StatusTest < ActionController::IntegrationTest

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
end
