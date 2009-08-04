require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase

  fixtures :users, :sites, :groups, :memberships

  def setup
    # @controller = Admin::UsersController.new
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
    @user = users(:blue)
    get :show, :user_id => @user.id
    assert_response :success
    assert_equal @user.login, assigns(:user).login
  end

  def test_new
  end

  def test_edit
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
