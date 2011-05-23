require File.dirname(__FILE__) + '/../test_helper'

class BugreportControllerTest < ActionController::TestCase
  fixtures :users

  def test_submit
    login_as :blue
    post :submit
    assert_redirected_to my_work_me_pages_url
  end

end
