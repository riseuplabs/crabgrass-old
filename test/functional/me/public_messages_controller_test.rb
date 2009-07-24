require File.dirname(__FILE__) + '/../../test_helper'

class Me::PublicMessagesControllerTest < ActionController::TestCase
  fixtures :users, :posts, :discussions

  def test_should_get_index
    get :index
    assert_login_required

    login_as :blue
    get :index
    assert assigns(:posts)
    assert_response :success
  end

  def test_show
    login_as :blue
    get :show, :id => users(:blue).discussion.posts.first.id
    assert assigns(:post)
    assert_response :success
  end

  def test_should_create
    login_as :red

    assert_difference 'Post.count' do
      assert_difference 'MessageWallActivity.count' do
        post :create, :post => {:body => 'h1. *hi*'}
      end
    end
    assert_response :redirect

    assert_equal 'h1. <strong>hi</strong>', Post.find(:last).body_html

    assert_no_difference 'Post.count' do
      post :create, :post => {:body => ''}
      assert_response :redirect
    end

    get :index
    assert_response :success
  end

  def test_should_destroy
    post = users(:blue).discussion.posts.first

    assert_no_difference('Post.count') do
      delete :destroy, :id => post.id
    end
    assert_login_required

    login_as :blue
    assert_difference('Post.count', -1) do
      delete :destroy, :id => post.id
    end
    assert_response :redirect
  end
end
