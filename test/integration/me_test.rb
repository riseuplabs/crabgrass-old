require "#{File.dirname(__FILE__)}/../test_helper"

class MeTest < ActionController::IntegrationTest
  def test_upload_avatar_icon
    login 'blue'
    visit '/me/edit'

    attach_file 'image[image_file]', "#{RAILS_ROOT}/test/fixtures/assets/0000/0001/bee.jpg", "image/jpeg"
    click_button 'Upload Image'

    assert_contain 'Successfully uploaded a new avatar image'
  end

  def pages_list_contains_owner_tooltip
    login 'blue'
    assert_have_selector 'a.tooltip'
  end

end
