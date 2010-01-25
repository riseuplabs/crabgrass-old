require File.dirname(__FILE__) + '/../test_helper'

class MessagePostsControllerTest < ActionController::TestCase
  fixtures :users, :relationships

  def test_should_create_message
    login_as :blue

    assert_no_difference 'Post.count' do
      post :create, :id => 'blue', :post => {:body => 'hi'}, :message_id => 'blue'
      assert_error_message
    end

    assert_no_difference 'Post.count' do
      post :create, :id => 'green', :post => {:body => ''}, :message_id => 'green'
      assert_error_message
    end

    assert_difference 'Post.count' do
      post :create, :id => 'green', :post => {:body => 'hi'}, :message_id => 'green'
    end
  end

end
