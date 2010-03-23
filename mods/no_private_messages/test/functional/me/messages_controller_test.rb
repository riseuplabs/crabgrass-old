require File.dirname(__FILE__) + '/../../test_helper'

class Me::MessagesControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :discussions


  def test_create_message_post
    login_as :blue
    # listing messages is disabled on cc.net
    get :index

    assert_redirected_to me_path
  end

end
