require File.dirname(__FILE__) + '/../../test_helper'

class Me::MessagePostsControllerTest < ActionController::TestCase
  fixtures :users, :relationships, :discussions


  def test_create_message_post
    login_as :blue

    # creating messages is disabled on cc.net
    assert_no_difference 'Post.count' do
      post :create, :message_id => users(:orange).to_param, :post => {:body => "blue: hi orange"}
    end

    assert_redirected_to me_path
  end

end
