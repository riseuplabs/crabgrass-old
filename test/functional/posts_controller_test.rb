require File.dirname(__FILE__) + '/../test_helper'
require 'posts_controller'

# Re-raise errors caught by the controller.
class PostsController; def rescue_action(e) raise e end; end

class PostsControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :groups, :user_participations, :group_participations, :discussions, :memberships, :sites

  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

# TODO: tests to ensure that users without access can't post

  def test_create
    login_as :red
    page = pages(:page1)
    assert_difference 'Page.find(%d).contributors_count' % page.id do
      post :create, :post => {:body => 'test post'}, :page_id   => page.id
      assert_equal 'test post', page.discussion.posts(true).last.body
    end
  end

  def test_edit
    login_as :red
    post :create, :post => {:body => 'test post'}, :page_id => pages(:page1).id
    post_id = pages(:page1).discussion.posts.last.id

    post :edit, :id => post_id
#    assert_template 'edit'
  end

  def test_save
    login_as :red
    post :create, :post => {:body => 'test post'}, :page_id => pages(:page1).id
    post_id = pages(:page1).discussion.posts.last.id

    post :save, :id => post_id, :body => 'new test post', :save => 'Save'
    assert pages(:page1).discussion.posts.last.body = 'new test post'

    post :save, :id => post_id, :body => 'new test post', :destroy => 'Delete'
    assert_nil pages(:page1).discussion.posts.detect { |post| post.body = 'new test post' }
  end

  def test_twinkle
    login_as :red
    post :create, :post => {:body => 'test post'}, :page_id => pages(:page1).id
    post_id = pages(:page1).discussion.posts.last.id
    assert_no_difference 'Post.find(post_id).ratings.count' do
      post :twinkle, :id => post_id
    end

    login_as :blue
    assert_difference 'Post.find(post_id).ratings.count' do
      post :twinkle, :id => post_id
    end
  end

  def test_untwinkle
    login_as :red
    post :create, :post => {:body => 'test post'}, :page_id => pages(:page1).id
    post_id = pages(:page1).discussion.posts.last.id

    login_as :blue
    post :twinkle, :id => post_id

    assert_difference 'Post.find(post_id).ratings.count', -1 do
      post :untwinkle, :id => post_id
    end
  end

end
