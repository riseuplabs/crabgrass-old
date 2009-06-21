require File.dirname(__FILE__) + '/../test_helper'

class ConversationsControllerTest < ActionController::TestCase
  fixtures :users, :relationships

#  def test_should_get_index
#    get :index
#    assert_response :success
#    assert_not_nil assigns(:discussions)
#  end

  def test_should_show_conversation
    login_as :blue

    discussion = nil
    assert_difference 'Discussion.count' do
      get :show, :id => users(:orange).to_param
      discussion = assigns(:discussion)
    end

    assert_no_difference 'Discussion.count' do
      get :show, :id => users(:orange).to_param
      assert_equal discussion, assigns(:discussion)
    end

    assert_response :success

    login_as :orange

    assert_no_difference 'Discussion.count' do
      get :show, :id => users(:blue).to_param
      assert_equal discussion, assigns(:discussion)
    end

    assert_response :success
  end

  def test_should_update_conversation
    login_as :blue

    assert_difference 'Post.count' do 
      put :update, :id => users(:orange).to_param, :post => {:body => 'hi'}
    end
  end

#  def test_should_destroy_conversation
#    assert_difference('Conversation.count', -1) do
#      delete :destroy, :id => conversations(:one).id
#    end
#    assert_redirected_to conversations_path
#  end
end
