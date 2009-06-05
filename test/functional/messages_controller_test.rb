require File.dirname(__FILE__) + '/../test_helper'

  def setup
    @controller = MessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

class MessagesControllerTest < ActionController::TestCase
  fixtures :pages, :users, :groups, :user_participations, :group_participations, :discussions, :memberships, :posts, :activities

  def test_create
    login_as :red
    assert_difference 'Post.count' do
      post :create,
        :post => {:body => 'test red to blue'},
        :user => 'blue', 
        :page_id => pages(:page1).id
      assert_response :redirect
    end
    assert Post.find(:last).body = 'test red to blue'
  end

  def test_index
    login_as :blue
    get :index, :user => 4  #self
    assert_response :success
    get :index, :user => 3  #friend
    assert_response :success
    get :index, :user => 2  #stranger
    assert_response :success
  end

  def test_show_no_login
    get :show, :user => 4, :id => 3
    assert_response :redirect
    assert_redirected_to :controller => :account, :action => :login
  end

  def test_show
    login_as :blue
    get :show, :user => 4, :id => 3
    assert_response :success
  end

  def test_destroy_other_user
    login_as :red
    # red can't destroy blue's Posts
    assert_no_difference 'Post.count' do
      post :destroy, :user => 'blue',
        :id => 3
      assert_response :redirect
    end
  end

  def test_destroy
    login_as :blue
    assert_difference 'Post.count', -1 do
      post :destroy, :user => 'blue',
        :id => 3
      assert_response :redirect
    end
  end

  def test_set_status
    login_as :red  # red does not have a discussion so far.
    assert_difference 'Post.count', 1 do
      post :set_status, :user => 'red',
        :post => {:body => 'testing set status on red.'}
      assert_response :redirect
    end
    assert Post.find(:last).body = 'testing set status on red'
    # not allowed to set status on other users:
    assert_no_difference 'Post.count' do
      post :set_status, :user => 'blue',
        :post => {:body => 'testing set status on blue.'}
      assert_response :redirect
    end

    # setting blank status does nothing
    assert_no_difference 'Post.count' do
      post :set_status, :user => 'red',
        :post => {:body => ''}
      assert_response :redirect
    end
  end

  # TODO: Test the creation and destruction of MessageWallActivities!

end
