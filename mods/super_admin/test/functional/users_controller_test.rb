require File.dirname(__FILE__) + '/../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships
  tests Admin::UsersController
  
  def setup
    # @controller = UsersController.new
    # @request = ActionController::TestRequest.new
    # @response = ActionController::TestResponse.new
  end
  
  def test_index
    login_as :blue
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  def test_show
    login_as :blue
    @user = users(:red)
    get :show, :user_id => @user.id
    assert_response :success
    assert_equal @user.login, assigns(:user).login
  end
  
  def test_new
    login_as :blue
    get :new
    assert_response :success
    assert assigns(:user)
  end
  
  def test_create
    login_as :blue
    post :create, :user => {:login => 'testuser', :display_name => 'TestUser', :email => 'testuser@testsite.com', :password => 'testpassword', :password_confirmation => 'testpassword' }
    assert_redirected :action => 'show'
    assert_equal assigns(:user).login, 'testuser'
    
    # todo: assert failing create test
  end
  
  def test_edit
    login_as :blue
    @user = users(:red)
    get :edit, :user_id => @user.id
    assert_response :success
    assert_equal @user.login, assigns(:user).login
  end
  
  def test_update
    login_as :blue
    @user = users(:red)
    # test change password and display name
    post :update, :user => {:login => @user.login, :display_name => 'RedRoot!', :email => @user.email, :password => 'changedpassword', :password_confirmation => 'changedpassword' }
    assert_redirected :action => 'show'
    assert_equal assigns(:user).login, 'RedRoot!'
  end
  
  def test_destroy
    login_as :blue
    @user = users(:red)
    get :destroy, :id => @user.login
    assert_redirected :action => 'index'
    assert_nil User.find_by_login(@user.login)
  end
end
