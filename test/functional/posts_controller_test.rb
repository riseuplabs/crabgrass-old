require File.dirname(__FILE__) + '/../test_helper'

class PostsControllerTest < ActionController::TestCase
  fixtures :pages, :users, :groups, :user_participations, :group_participations, :discussions, :memberships, :sites, :posts

# TODO: tests to ensure that users without access can't post

  def test_create
    page = pages(:page1)
    login_as :red
    # contributors_count does not get incremented if the user is the same
    # so since we're still red this should not  change
    assert_no_difference 'Page.find(%d).contributors_count' % page.id do
      post :create, :post => {:body => 'test post'}, :page_id   => page.id
      assert_equal 'test post', page.discussion.posts(true).last.body
    end

    post :create, :post => {:body => ''}, :page_id   => page.id
    assert_response :redirect
    assert flash[:bad_reply] 
  end

  def test_edit
    login_as :red
    post_id = posts(:reds_post).id
    post :edit, :id => post_id

    assert_response :success
#    assert_template 'edit'
  end

  def test_save
    login_as :red
    post_id = posts(:reds_post).id

    post :save, :id => post_id, :body => 'new test post', :save => 'Save'
    assert_equal 'new test post',  Post.find(post_id).body

    post :save, :id => post_id, :body => 'new test post', :destroy => 'Delete'
    assert_nil pages(:page1).discussion.posts.detect { |post| post.body == 'new test post' }
  end

  def test_no_twinkle_with_same_user
    post_id = posts(:reds_post).id

    login_as :red
    assert_no_difference 'Post.find(post_id).ratings.count' do
      post :twinkle, :id => post_id
    end
  end

  def test_twinkle
    post_id = posts(:reds_post).id

    login_as :blue
    assert_difference 'Post.find(post_id).ratings.count' do
      post :twinkle, :id => post_id
    end
  end

  def test_untwinkle
    reds_post = posts(:reds_post)
    reds_post.ratings.create(:user_id => users(:blue).id, :rating => 1)
    post_id = reds_post.id

    login_as :blue
    assert_difference 'Post.find(post_id).ratings.count', -1 do
      post :untwinkle, :id => post_id
    end
  end

  def test_jump
    login_as :red
    post :create, :post => {:body => 'test post'}, :page_id => pages(:page1).id
    get :jump, :id => pages(:page1).discussion.posts.last.id, :page_id => pages(:page1).id
    assert_response :redirect
  end

end
