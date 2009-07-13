require File.dirname(__FILE__) + '/../../test_helper'

class People::MessagesControllerTest < ActionController::TestCase
  fixtures :users, :discussions, :posts, :profiles

  def test_index
    login_as :red
    get :index, :person_id => users(:blue).to_param
    assert_not_nil assigns(:posts)
    assert_response :success
  end

  def test_create
    assert_no_difference 'Post.count' do
      post :create, :post => {:body => 'x'}, :person_id => 'blue'
      assert_login_required
    end

    login_as :red

    assert_difference 'Post.count', 1, '+1 post' do
      assert_difference 'MessageWallActivity.count', 1, '+1 activity' do
        post :create, :post => {:body => 'h1. *hi*'}, :person_id => 'blue'
        assert_not_nil assigns(:post)
        assert_response :redirect
      end
    end
  end
  
  def test_may_not_create
    login_as :red

    profile = users(:blue).profile
    assert_not_nil profile.id
    profile.may_comment = false
    profile.save!

    assert_no_difference 'Post.count', '+0 post' do
      assert_no_difference 'MessageWallActivity.count', '+0 activity' do
        post :create, :post => {:body => 'h1. *hi*'}, :person_id => 'blue'
        assert_permission_denied
      end
    end
  end

  def test_destroy
    # both blue and red should be able to destroy blue's post to red's wall
    [:blue, :red].each do |user|
      post = create_post( :from => users(:blue), :to => users(:red) )

      login_as :yellow
      assert_no_difference 'Post.count', '+0 post' do
        delete :destroy, :person_id => 'red', :id => post.id
      end

      login_as user
      assert_difference 'Post.count', -1, '-1 post' do
        assert_difference 'MessageWallActivity.count', -1, '-1 activity' do
          delete :destroy, :person_id => 'red', :id => post.id
        end
      end
    end
  end
  
  protected
 
  def create_post(opts)
    PublicPost.create do |post|
      post.body = 'x'
      post.discussion = opts[:to].discussion
      post.user = opts[:from]
      post.recipient = opts[:to]
      post.body_html = post.lite_html
    end
  end

end


